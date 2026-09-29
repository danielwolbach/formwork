//
//  Workout.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 04.09.26.
//

import Foundation
import SwiftData

@Model
public class Workout {
    public var name: String = ""

    public var pictogram: Pictogram = Pictogram(image: "clipboard", tint: .blue)

    public var schedule: Schedule = Schedule.weekly()

    @Relationship(deleteRule: .cascade, inverse: \WorkoutEntry.workout)
    public var entries: [WorkoutEntry] = []

    @Relationship(deleteRule: .nullify, inverse: \Session.workout)
    public var sessions: [Session] = []

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

    public var exerciseCategories: [Exercise.Category] {
        let counts = entries
            .compactMap(\.exercise)
            .flatMap(\.categories)
            .reduce(into: [:]) { counts, category in counts[category, default: 0] += 1 }

        return Exercise.Category.allCases
            .filter { counts[$0] != nil }
            .sorted { counts[$0, default: 0] > counts[$1, default: 0] }
    }

    public func append(exercise: Exercise, target: ExerciseTarget) {
        let entry = WorkoutEntry(exercise: exercise, target: target)
        entry.order = (entries.map(\.order).max() ?? -1) + 1
        entries.append(entry)
    }

    public func startSession() -> Session? {
        guard let modelContext else {
            // TODO: Log error.
            return nil
        }

        let runningDescriptor = FetchDescriptor<Session>(predicate: #Predicate { $0.endDate == nil })

        do {
            for running in try modelContext.fetch(runningDescriptor) {
                running.discard()
            }
        } catch {
            // TODO: Log error.
            return nil
        }

        let session = Session(workout: self)
        modelContext.insert(session)

        do {
            try modelContext.save()
        } catch {
            // TODO: Log error.
            return nil
        }

        return session
    }
}

extension [Workout] {
    public func pending(on date: Date = .now, calendar: Calendar = .current) -> [Workout] {
        guard let day = calendar.dateInterval(of: .day, for: date) else {
            return []
        }

        return filter { $0.schedule.isScheduled(on: date, in: calendar) }
            .filter { workout in !workout.sessions.contains { !$0.isActive && $0.falls(into: day, in: calendar) } }
            .map { workout in
                let startMinute = workout.sessions
                    .filter { !$0.isActive }
                    .compactMap { $0.startMinute(in: calendar) }
                    .clockMedoid
                return (workout, startMinute)
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
