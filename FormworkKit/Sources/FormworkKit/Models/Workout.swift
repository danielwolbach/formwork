//
//  Workout.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import SwiftData

@Model
public final class Workout {
    public var name: String = "" // TODO: Unknown workout title.

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

    public func append(exercise: Exercise, target: ExerciseTarget) {
        let order = (entries.map(\.order).max() ?? -1) + 1
        entries.append(WorkoutEntry(order: order, exercise: exercise, target: target))
    }
}
