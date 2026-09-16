//
//  DayState.swift
//  Formwork
//
//  Created by Daniel Wolbach on 06.09.26.
//

import FormworkKit
import Foundation
import SwiftData

enum DayState {
    case remaining([Workout])
    case finished
    case unscheduled
}

extension DayState {
    init(workouts: [Workout], sessions: [Session], on date: Date = .now) {
        let calendar = Calendar.autoupdatingCurrent
        let scheduled = workouts.filter { $0.schedule.matches(date) }

        guard !scheduled.isEmpty else {
            self = .unscheduled
            return
        }

        let midnight = calendar.startOfDay(for: date)
        var missing = Set(scheduled.map(\.persistentModelID))
        var completed: Set<PersistentIdentifier> = []
        var startTimes: [PersistentIdentifier: TimeInterval] = [:]

        for session in sessions {
            guard let workout = session.workout?.persistentModelID else {
                continue
            }

            if startTimes[workout] == nil {
                startTimes[workout] = session.started
                    .timeIntervalSince(calendar.startOfDay(for: session.started))
                missing.remove(workout)
            }

            if session.completion != nil, calendar.isDate(session.started, inSameDayAs: date) {
                completed.insert(workout)
            }

            if missing.isEmpty, session.started < midnight {
                break
            }
        }

        let remaining = scheduled
            .filter { !completed.contains($0.persistentModelID) }
            .sorted { lhs, rhs in
                switch (startTimes[lhs.persistentModelID], startTimes[rhs.persistentModelID]) {
                case let (left?, right?) where left != right:
                    left < right
                case (nil, .some):
                    false
                case (.some, nil):
                    true
                default:
                    lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
                }
            }

        self = remaining.isEmpty ? .finished : .remaining(remaining)
    }

    var next: Workout? {
        guard case let .remaining(workouts) = self else {
            return nil
        }

        return workouts.first { !$0.entries.isEmpty }
    }
}
