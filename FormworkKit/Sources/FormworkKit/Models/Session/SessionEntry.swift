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

/// How long an exercise took within its session.
public extension SessionEntry {
    var elapsed: TimeInterval? {
        guard let session, let resolved = status.resolved else {
            return nil
        }

        // One pass: every exercise of the session asks this, so each allocating a list of the others' times
        // over again is the session's own length squared.
        var previous = session.started

        for other in session.entries {
            if let other = other.status.resolved, other < resolved, other > previous {
                previous = other
            }
        }

        return resolved.timeIntervalSince(previous)
    }
}

/// How an exercise went compared with the last times it was done.
public extension SessionEntry {
    var isPersonalBest: Bool {
        guard status.isCompleted, let exercise, target.type == exercise.type, session?.isActive == false else {
            return false
        }

        guard let best = earlier.map(\.target.rank).max() else {
            return false
        }

        return target.rank > best
    }

    var previousBest: ExerciseTarget? {
        guard status.isCompleted, let exercise, target.type == exercise.type, session?.isActive == false else {
            return nil
        }

        return earlier.map(\.target).max { $0.rank < $1.rank }
    }

    var improvement: Double? {
        guard let previousBest, previousBest.rank > 0 else {
            return nil
        }

        return (target.rank - previousBest.rank) / previousBest.rank
    }

    var change: Change? {
        guard let previous = earlier.max(by: { ($0.session?.started ?? .distantPast) < ($1.session?.started ?? .distantPast) })?.target else {
            return nil
        }

        let difference = target.rank - previous.rank

        guard difference != 0 else {
            return nil
        }

        // Reps are the one rank that isn't a measurement, so they have no quantity to carry the difference.
        var quantity: Quantity? = switch target {
        case let .weight(current): current.weight
        case .bodyweight: nil
        case let .duration(current): current.duration
        case let .distance(current): current.distance
        }
        quantity?.base = abs(difference)

        return Change(
            difference: difference,
            magnitude: quantity?.formatted ?? String(localized: .exerciseTargetRepsTitle(Int(abs(difference))))
        )
    }

    struct Change: Sendable {
        public let difference: Double
        public let magnitude: String
    }
}

private extension SessionEntry {
    var earlier: [SessionEntry] {
        guard let session, !session.isActive, let exercise, target.type == exercise.type else {
            return []
        }

        return (workoutEntry?.sessionEntries ?? []).filter { other in
            guard let theirs = other.session, !theirs.isActive else {
                return false
            }

            // The type has to match: `rank` would otherwise weigh reps against kilograms.
            return other.status.isCompleted && other.target.type == exercise.type && theirs.started < session.started
        }
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
