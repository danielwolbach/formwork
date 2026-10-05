//
//  SessionEntry.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 05.09.26.
//

import Foundation
import SwiftData

@Model
public class SessionEntry {
    public enum Status: Codable, Hashable, Sendable {
        case pending
        case completed(date: Date)
        case skipped(date: Date)
    }

    public var identifier: UUID = UUID()

    public var order: Int = 0

    public var exercise: Exercise?

    public var target: ExerciseTarget = ExerciseTarget.bodyweight()

    public var status: Status = Status.pending

    public var session: Session?

    public var workoutEntry: WorkoutEntry?

    public var creationDate: Date = Date.distantPast

    init(entry: WorkoutEntry) {
        self.identifier = UUID()
        self.order = entry.order
        self.exercise = entry.exercise
        self.target = entry.target
        self.status = .pending
        self.workoutEntry = entry
        self.creationDate = .now
    }
}

extension SessionEntry {
    public var pictogram: Pictogram {
        exercise?.pictogram ?? .unknown
    }

    public var title: String {
        exercise?.title ?? .init(localized: .exerciseDeletedTitle)
    }

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
        guard status.isCompleted, let session, !session.isActive, let exercise, target.exerciseKind == exercise.kind else {
            return []
        }

        let sessionEntries = workoutEntry?.sessionEntries ?? []

        return sessionEntries.filter { other in
            guard let theirs = other.session, !theirs.isActive else {
                return false
            }

            return other.status.isCompleted
                && other.target.exerciseKind == exercise.kind
                && theirs.startDate < session.startDate
        }
    }
}

extension SessionEntry: Comparable {
    public static func < (lhs: borrowing SessionEntry, rhs: borrowing SessionEntry) -> Bool {
        lhs.order < rhs.order
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

extension SessionEntry.Status {
    public var pictogram: Pictogram {
        switch self {
        case .pending: Pictogram(image: "ellipsis.circle.fill", tint: .gray)
        case .completed: Pictogram(image: "checkmark.circle.fill", tint: .green)
        case .skipped: Pictogram(image: "arrowtriangle.forward.circle.fill", tint: .orange)
        }
    }
}
