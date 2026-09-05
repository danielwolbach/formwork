//
//  SessionEntry.swift
//  Formwork
//
//  Created by Daniel Wolbach on 05.09.26.
//

import Foundation
import SwiftData

@Model
final class SessionEntry {
    var identifier: UUID = UUID()

    var order: Int = 0

    var status: Status = Status.pending

    var target: ExerciseTarget = ExerciseTarget.bodyweight(sets: 1, reps: 1)

    var exercise: Exercise? = nil

    var workoutEntry: WorkoutEntry? = nil

    var session: Session? = nil
    
    init(workoutEntry: WorkoutEntry) {
        self.identifier = UUID()
        self.order = workoutEntry.order
        self.exercise = workoutEntry.exercise
        self.target = workoutEntry.target
        self.workoutEntry = workoutEntry
    }
}

extension SessionEntry {
    nonisolated enum Status: Codable, Hashable {
        case pending
        case completed(at: Date)
        case skipped(at: Date)

        var isPending: Bool {
            if case .pending = self { true } else { false }
        }

        var isCompleted: Bool {
            if case .completed = self { true } else { false }
        }

        var isSkipped: Bool {
            if case .skipped = self { true } else { false }
        }

        var resolved: Date? {
            switch self {
            case .pending: nil
            case let .completed(date), let .skipped(date): date
            }
        }
    }
}

extension SessionEntry: Comparable {
    static func < (lhs: borrowing SessionEntry, rhs: borrowing SessionEntry) -> Bool {
        lhs.order < rhs.order
    }
}
