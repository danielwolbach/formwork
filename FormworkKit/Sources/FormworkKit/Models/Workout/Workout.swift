//
//  Workout.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import Foundation
import SwiftData

@Model
public final class Workout {
    public var name: String = String(localized: .workoutUnknownTitle)

    public var pictogram: Pictogram = Pictogram.unknown

    public var schedule: Schedule = Schedule.inactive

    @Relationship(deleteRule: .cascade, inverse: \WorkoutEntry.workout)
    public var entries: [WorkoutEntry] = []

    @Relationship(deleteRule: .nullify, inverse: \Session.workout)
    var sessions: [Session] = []

    public init(name: String, pictogram: Pictogram, schedule: Schedule, entries: [WorkoutEntry]) {
        self.name = name
        self.pictogram = pictogram
        self.schedule = schedule
        self.entries = entries
    }
}

public extension Workout {
    func append(exercise: Exercise, target: ExerciseTarget) {
        let order = (entries.map(\.order).max() ?? -1) + 1
        entries.append(WorkoutEntry(order: order, exercise: exercise, target: target))
    }
}

extension Workout: Displayable {
    public var title: String {
        name
    }

    public var subtitle: String? {
        String(localized: Exercise.countTitle(entries.count))
    }
}

public extension [Workout] {
    func pending(on date: Date = .now, calendar: Calendar = .current) -> [Workout] {
        guard let day = calendar.dateInterval(of: .day, for: date) else { return [] }

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
