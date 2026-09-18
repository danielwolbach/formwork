//
//  SessionEntry.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 05.09.26.
//

import Foundation
import SwiftData

@Model
public final class SessionEntry: Comparable {
    public var identifier: UUID = UUID()

    public var order: Int = 0

    public var status: Status = Status.pending

    public var target: ExerciseTarget = ExerciseTarget.bodyweight(target: .init(sets: 1, reps: 1))

    public var exercise: Exercise?

    public var workoutEntry: WorkoutEntry?

    public var session: Session?

    public init(workoutEntry: WorkoutEntry) {
        self.identifier = UUID()
        self.order = workoutEntry.order
        self.exercise = workoutEntry.exercise
        self.target = workoutEntry.target
        self.workoutEntry = workoutEntry
    }

    public static func < (lhs: borrowing SessionEntry, rhs: borrowing SessionEntry) -> Bool {
        lhs.order < rhs.order
    }
}

public extension SessionEntry {
    enum Status: Codable, Hashable, Sendable {
        case pending
        case completed(at: Date)
        case skipped(at: Date)

        public var isPending: Bool {
            if case .pending = self {
                true
            } else {
                false
            }
        }

        public var isCompleted: Bool {
            if case .completed = self {
                true
            } else {
                false
            }
        }

        public var isSkipped: Bool {
            if case .skipped = self {
                true
            } else {
                false
            }
        }

        public var resolved: Date? {
            switch self {
            case .pending: nil
            case let .completed(date), let .skipped(date): date
            }
        }
    }
}
