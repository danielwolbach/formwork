//
//  StatisticPin.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 02.10.26.
//

import Foundation
import SwiftData

@Model
public class StatisticPin {
    public var order: Int = 0

    public var kind: StatisticKind = StatisticKind.weekStreak

    public var workout: Workout?

    public var exercise: Exercise?

    public var entry: WorkoutEntry?

    public var creationDate: Date = Date.distantPast

    public init(_ kind: StatisticKind, of subject: History.Subject, order: Int) {
        self.order = order
        self.kind = kind
        self.creationDate = .now

        switch subject {
        case .all: break
        case let .workout(workout): self.workout = workout
        case let .exercise(exercise): self.exercise = exercise
        case let .entry(entry): self.entry = entry
        }
    }
}

extension StatisticPin {
    public var subject: History.Subject {
        if let workout {
            .workout(workout)
        } else if let exercise {
            .exercise(exercise)
        } else if let entry {
            .entry(entry)
        } else {
            .all
        }
    }

    public var isArchived: Bool {
        workout?.isArchived == true || exercise?.isArchived == true || entry?.isArchived == true || entry?.workout?.isArchived == true
    }

    public static func append(_ kind: StatisticKind, of subject: History.Subject, into context: ModelContext) throws {
        var descriptor = FetchDescriptor<StatisticPin>(sortBy: [SortDescriptor(\.order, order: .reverse)])
        descriptor.fetchLimit = 1
        let last = try context.fetch(descriptor).first

        context.insert(StatisticPin(kind, of: subject, order: (last?.order ?? -1) + 1))
    }

    /// Swaps with the neighbour in `pins`, so pins hidden from it keep their place.
    public func move(by offset: Int, among pins: [StatisticPin]) {
        guard let index = pins.firstIndex(of: self), pins.indices.contains(index + offset) else {
            return
        }

        let other = pins[index + offset]

        (order, other.order) = (other.order, order)
    }
}
