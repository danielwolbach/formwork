//
//  Workout.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 04.09.26.
//

import Foundation
import OSLog
import SwiftData

@Model
public final class Workout {
    public var id: UUID = UUID()

    public var name: String = ""

    public var pictogram: Pictogram = Pictogram(image: "clipboard", tint: .blue)

    public var schedule: Schedule = Schedule.weekly()

    @Relationship(deleteRule: .cascade, inverse: \WorkoutEntry.workout)
    public var entries: [WorkoutEntry]? = []

    @Relationship(deleteRule: .nullify, inverse: \Session.workout)
    public var sessions: [Session]? = []

    public var isArchived: Bool = false

    public var creationDate: Date = Date.distantPast

    public init(name: String, pictogram: Pictogram, schedule: Schedule, entries: [WorkoutEntry]) {
        for (index, entry) in entries.enumerated() {
            entry.order = index
        }

        self.name = name
        self.pictogram = pictogram
        self.schedule = schedule
        self.entries = entries
        self.creationDate = .now
    }
}

extension Workout {
    public var title: String {
        name
    }

    public var isStartable: Bool {
        !isArchived && (entries ?? []).contains { !$0.isArchived }
    }

    public var exerciseCategories: [Exercise.Category] {
        let counts = (entries ?? [])
            .filter { !$0.isArchived }
            .compactMap(\.exercise)
            .flatMap(\.categories)
            .reduce(into: [:]) { counts, category in counts[category, default: 0] += 1 }

        return Exercise.Category.allCases
            .filter { counts[$0] != nil }
            .sorted { counts[$0, default: 0] > counts[$1, default: 0] }
    }

    public func isScheduled(on date: Date = .now, now: Date = .now, in calendar: Calendar = .current) -> Bool {
        schedule.isScheduled(on: date, after: lastSession(before: calendar.startOfDay(for: date), in: calendar), now: now, in: calendar)
    }

    public func isDue(on date: Date = .now, now: Date = .now, in calendar: Calendar = .current) -> Bool {
        schedule.isDue(on: date, after: lastSession(in: calendar), now: now, in: calendar)
    }

    public func lastSession(before limit: Date? = nil, in calendar: Calendar = .current) -> Date? {
        (sessions ?? [])
            .filter { !$0.isActive }
            .map { $0.localStartDate(in: calendar) }
            .filter { $0 < limit ?? .distantFuture }
            .max()
    }

    public func append(exercise: Exercise, target: ExerciseTarget) {
        let entry = WorkoutEntry(exercise: exercise, target: target)
        entry.order = ((entries ?? []).map(\.order).max() ?? -1) + 1
        entries = (entries ?? []) + [entry]
    }

    public func startSession() -> Session? {
        guard let modelContext else {
            Logger.session.fault("Starting session failed: workout has no model context")
            return nil
        }

        let running: [Session]

        do {
            running = try modelContext.fetch(Session.activeDescriptor)
        } catch {
            Logger.session.error("Starting session failed while fetching running sessions: \(error, privacy: .public)")
            return nil
        }

        for session in running {
            session.discard()
        }

        let session = Session(workout: self)
        modelContext.insert(session)

        do {
            try modelContext.save()
        } catch {
            Logger.session.error("Saving started session failed: \(error, privacy: .public)")
            return nil
        }

        let count = session.entries?.count ?? 0
        Logger.session.info("Started session with \(count) entries, replacing \(running.count) running")

        return session
    }

    func typicalStartMinute(at now: Date, in calendar: Calendar) -> Int? {
        History(.workout(self), among: sessions ?? [], at: now, calendar: calendar).typicalStartMinute
    }
}

extension [Workout] {
    public func pending(on date: Date = .now, calendar: Calendar = .current) -> [Workout] {
        pending(on: date, calendar: calendar) { $0.lastSession(in: calendar) } startMinute: { $0.typicalStartMinute(at: date, in: calendar) }
    }

    func pending(
        on date: Date,
        calendar: Calendar,
        lastSession: (Workout) -> Date?,
        startMinute: (Workout) -> Int?
    ) -> [Workout] {
        filter { $0.schedule.isDue(on: date, after: lastSession($0), now: date, in: calendar) }
            .map { workout in
                (workout, startMinute(workout))
            }
            .sorted { lhs, rhs in
                switch (lhs.1, rhs.1) {
                case let (left?, right?) where left != right: left < right
                case (_?, nil): true
                case (nil, _?): false
                default: lhs.0.name.localizedStandardCompare(rhs.0.name) == .orderedAscending
                }
            }
            .map(\.0)
    }
}
