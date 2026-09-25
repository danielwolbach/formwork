//
//  SessionEntry.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 05.09.26.
//

import Foundation
import SwiftData

@Model
public final class SessionEntry {
    public enum Status: Codable, Hashable, Sendable {
        case pending
        case completed(at: Date)
        case skipped(at: Date)
    }

    public var identifier: UUID = UUID()

    public var order: Int = 0

    public var status: Status = Status.pending

    public var target: ExerciseTarget = ExerciseTarget.bodyweight(.init(sets: 1, reps: 1))

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
}

extension SessionEntry: Comparable {
    public static func < (lhs: borrowing SessionEntry, rhs: borrowing SessionEntry) -> Bool {
        lhs.order < rhs.order
    }
}

extension SessionEntry {
    public var duration: TimeInterval? {
        guard let session, let resolved = status.resolvedDate else {
            return nil
        }

        var previous = session.startDate

        for other in session.entries {
            if let other = other.status.resolvedDate, other < resolved, other > previous {
                previous = other
            }
        }

        return resolved.timeIntervalSince(previous)
    }

    public var isBest: Bool {
        previousBest.map { target.rank > $0.rank } ?? false
    }

    public var previous: ExerciseTarget? {
        earlier.max { ($0.session?.startDate ?? .distantPast) < ($1.session?.startDate ?? .distantPast) }?.target
    }

    public var previousBest: ExerciseTarget? {
        earlier.map(\.target).max { $0.rank < $1.rank }
    }

    private var earlier: [SessionEntry] {
        guard status.isCompleted, let session, !session.isActive, let exercise, target.type == exercise.type else {
            return []
        }

        return (workoutEntry?.sessionEntries ?? []).filter { other in
            guard let theirs = other.session, !theirs.isActive else {
                return false
            }

            return other.status.isCompleted
                && other.target.type == exercise.type
                && theirs.startDate < session.startDate
        }
    }
}

extension SessionEntry: Displayable {
    public var pictogram: Pictogram {
        exercise?.pictogram ?? .unknown
    }

    public var title: String {
        exercise?.title ?? String(localized: .exerciseUnknownTitle)
    }

    public var subtitle: String? {
        target.subtitle
    }
}

extension SessionEntry.Status {
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

    public var resolvedDate: Date? {
        switch self {
        case .pending: nil
        case let .completed(date), let .skipped(date): date
        }
    }
}

extension SessionEntry.Status: Displayable {
    public var pictogram: Pictogram {
        switch self {
        case .pending: .pendingBadge
        case .completed: .completedBadge
        case .skipped: .skippedBadge
        }
    }

    public var title: String {
        switch self {
        case .pending: String(localized: .sessionEntryStatusPendingTitle)
        case .completed: String(localized: .sessionEntryStatusCompletedTitle)
        case .skipped: String(localized: .sessionEntryStatusSkippedTitle)
        }
    }
}
