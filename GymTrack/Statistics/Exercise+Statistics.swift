//
//  Exercise+Statistics.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 06.08.26.
//

import Foundation

struct ExerciseTargetTrend {
    let value: String
    let isIncrease: Bool
}

struct ExerciseTargetDataPoint: Identifiable {
    let date: Date
    let target: ExerciseTarget

    var id: Date {
        date
    }

    var value: Double {
        target.primaryTargetValue
    }
}

@MainActor
extension Exercise {
    private static let targetHistoryLimit = 8

    var finishedSessionEntries: [SessionEntry] {
        sessionEntries.filter { $0.session?.ended != nil }
    }

    var completedSessionEntries: [SessionEntry] {
        finishedSessionEntries.filter { $0.status == .done }
    }

    var skippedSessionEntries: [SessionEntry] {
        finishedSessionEntries.filter { $0.status == .skipped }
    }

    var performedSessionEntries: [SessionEntry] {
        (completedSessionEntries + skippedSessionEntries)
            .sorted { ($0.session?.ended ?? .distantPast) > ($1.session?.ended ?? .distantPast) }
    }

    var completedExecutionCount: Int {
        completedSessionEntries.count
    }

    var skippedExecutionCount: Int {
        skippedSessionEntries.count
    }

    var completionRate: Double? {
        let executionCount = completedExecutionCount + skippedExecutionCount
        guard executionCount > 0 else {
            return nil
        }

        return Double(completedExecutionCount) / Double(executionCount)
    }

    var lastPerformedDate: Date? {
        performedSessionEntries.first?.session?.ended
    }

    var lastTarget: ExerciseTarget? {
        performedSessionEntries.first?.target
    }

    var highestCompletedTarget: ExerciseTarget? {
        completedSessionEntries.max { $0.target.primaryTargetValue < $1.target.primaryTargetValue }?.target
    }

    var recentTargetHistory: [ExerciseTargetDataPoint] {
        performedSessionEntries
            .prefix(Self.targetHistoryLimit)
            .compactMap { entry in
                guard let ended = entry.session?.ended else {
                    return nil
                }

                return ExerciseTargetDataPoint(date: ended, target: entry.target)
            }
            .sorted { $0.date < $1.date }
    }

    var recentTargetTrend: ExerciseTargetTrend? {
        let history = recentTargetHistory
        guard let first = history.first, let last = history.last, history.count > 1 else {
            return nil
        }

        guard let change = last.target.primaryTargetChangeText(from: first.target) else {
            return nil
        }

        return ExerciseTargetTrend(
            value: change,
            isIncrease: last.target.primaryTargetValue > first.target.primaryTargetValue
        )
    }
}

extension ExerciseTarget {
    var primaryTargetValue: Double {
        switch self {
        case let .weight(weight, _, _): weight
        case let .bodyweight(_, reps): Double(reps)
        case let .duration(minutes): Double(minutes)
        case let .distance(meters): Double(meters)
        }
    }

    var primaryTargetText: String {
        formattedPrimaryTargetValue(primaryTargetValue)
    }

    func primaryTargetChangeText(from previous: Self) -> String? {
        guard type == previous.type else {
            return nil
        }

        let difference = primaryTargetValue - previous.primaryTargetValue
        guard difference != 0 else {
            return nil
        }

        let sign = difference > 0 ? "+" : "−"
        return "\(sign)\(formattedPrimaryTargetValue(abs(difference)))"
    }

    func formattedPrimaryTargetValue(_ value: Double) -> String {
        let unit: LocalizedStringResource = switch self {
        case .weight: .unitKilograms
        case .bodyweight: .exerciseTargetFieldReps
        case .duration: .unitMinutes
        case .distance: .unitMeters
        }

        return "\(value.formatted()) \(String(localized: unit))"
    }
}
