//
//  WorkoutEntry.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 04.09.26.
//

import Foundation
import SwiftData

@Model
public class WorkoutEntry {
    public var order: Int = 0

    public var target: ExerciseTarget = ExerciseTarget.bodyweight()

    public var exercise: Exercise?

    public var workout: Workout?

    @Relationship(deleteRule: .nullify, inverse: \SessionEntry.workoutEntry)
    public var sessionEntries: [SessionEntry] = []

    public var creationDate: Date = Date.distantPast

    public init(exercise: Exercise? = nil, target: ExerciseTarget) {
        self.exercise = exercise
        self.target = target
        self.creationDate = .now
    }
}

extension WorkoutEntry: Comparable {
    public static func < (lhs: borrowing WorkoutEntry, rhs: borrowing WorkoutEntry) -> Bool {
        lhs.order < rhs.order
    }
}

extension WorkoutEntry {
    public var pictogram: Pictogram {
        exercise?.pictogram ?? .unknown
    }

    public var title: String {
        exercise?.title ?? .init(localized: .exerciseDeletedTitle)
    }

    public var isArchived: Bool {
        exercise?.isArchived ?? false
    }
}
