//
//  DayState.swift
//  Formwork
//
//  Created by Daniel Wolbach on 06.09.26.
//

import FormworkKit
import Foundation

enum DayState {
    case remaining([Workout])
    case finished
    case unscheduled
}

extension DayState {
    init(workouts: [Workout], statistics: Statistics, on date: Date = .now) {
        let scheduled = workouts.filter { $0.schedule.matches(date) }

        guard !scheduled.isEmpty else {
            self = .unscheduled
            return
        }

        let remaining = scheduled
            .filter { !statistics[$0].hasCompletion(on: date) }
            .map { workout in (workout: workout, time: statistics[workout].lastStartTimeOfDay) }
            .sorted { lhs, rhs in
                switch (lhs.time, rhs.time) {
                case let (left?, right?) where left != right:
                    left < right
                case (nil, .some):
                    false
                case (.some, nil):
                    true
                default:
                    lhs.workout.name.localizedStandardCompare(rhs.workout.name) == .orderedAscending
                }
            }
            .map(\.workout)

        self = remaining.isEmpty ? .finished : .remaining(remaining)
    }

    var next: Workout? {
        guard case let .remaining(workouts) = self else {
            return nil
        }

        return workouts.first { !$0.entries.isEmpty }
    }
}
