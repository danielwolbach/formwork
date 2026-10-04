//
//  Records.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 04.10.26.
//

import Foundation

extension History.Window {
    var dailyBests: [Progression.Point] {
        guard let exercise = history.subject.exercise else {
            return []
        }

        let best = entries
            .filter { $0.status.isCompleted && $0.target.exerciseKind == exercise.kind }
            .reduce(into: [Date: ExerciseTarget]()) { best, entry in
                guard let day = entry.session?.period(of: .day, in: history.calendar)?.start else {
                    return
                }

                if best[day].map({ $0.rank < entry.target.rank }) ?? true {
                    best[day] = entry.target
                }
            }

        return best
            .sorted { $0.key < $1.key }
            .map { Progression.Point(date: $0.key, target: $0.value) }
    }

    var personalBest: ExerciseTarget? {
        dailyBests.map(\.target).max { $0.rank < $1.rank }
    }

    var typicalBest: ExerciseTarget? {
        let ranked = dailyBests.map(\.target).sorted { $0.rank < $1.rank }
        return ranked.isEmpty ? nil : ranked[(ranked.count - 1) / 2]
    }

    var oneRepMax: Double? {
        entries
            .filter(\.status.isCompleted)
            .compactMap { entry -> Double? in
                guard case let .weight(kilograms, reps, _) = entry.target, reps > 0 else {
                    return nil
                }

                return kilograms * (1 + Double(reps) / 30)
            }
            .max()
    }

    var totalVolume: Double? {
        let volume = entries
            .filter(\.status.isCompleted)
            .compactMap(\.target.volume)
            .reduce(0, +)

        return volume == 0 ? nil : volume
    }
}
