//
//  Formula.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 10.10.26.
//

import Foundation

public enum Formula: Hashable, Sendable {
    case count
    case perWeek
    case typicalGap
    case latest
    case typical(Quantity)
    case total(Quantity)
    case maximum(Quantity)
    case share(Quantity, of: Quantity)
    case mostFrequent(Pick)

    public enum Pick: Hashable, Sendable {
        case workout
        case exercise
        case skippedExercise
    }
}

extension Formula {
    public var isRecord: Bool {
        switch self {
        case .latest, .maximum: true
        default: false
        }
    }

    public var isNumeric: Bool {
        switch self {
        case .latest, .mostFrequent: false
        case let .typical(quantity), let .total(quantity), let .maximum(quantity): !quantity.isClock
        case .count, .perWeek, .typicalGap, .share: true
        }
    }

    var isPerOccurrence: Bool {
        switch self {
        case .typical, .total, .maximum, .share: true
        case .count, .perWeek, .typicalGap, .latest, .mostFrequent: false
        }
    }

    func unit(in history: History) -> Reading.Unit? {
        switch self {
        case .count: .count
        case .perWeek: .rate
        case .typicalGap: .days
        case .share: .percent
        case let .typical(quantity), let .total(quantity), let .maximum(quantity): quantity.unit(in: history)
        case .latest, .mostFrequent: nil
        }
    }

    func value(of occurrence: Occurrence, in calendar: Calendar) -> Double? {
        switch self {
        case let .typical(quantity), let .total(quantity), let .maximum(quantity):
            return quantity.value(of: occurrence, in: calendar)
        case let .share(part, whole):
            guard let whole = whole.value(of: occurrence, in: calendar), whole > 0, let part = part.value(of: occurrence, in: calendar) else {
                return nil
            }

            return part / whole
        case .count, .perWeek, .typicalGap, .latest, .mostFrequent:
            return nil
        }
    }

    func sampleCount(in period: Period) -> Int {
        guard isPerOccurrence else {
            return period.occurrences.count
        }

        return period.occurrences.count { value(of: $0, in: period.history.calendar) != nil }
    }
}

extension Period {
    public func value(_ formula: Formula) -> Double? {
        let calendar = history.calendar

        switch formula {
        case .count:
            return Double(completions.count)
        case .perWeek:
            guard let days = calendar.dateComponents([.day], from: interval.start, to: interval.end).day, days > 0 else {
                return nil
            }

            return Double(completions.count) / (Double(max(days, 7)) / 7)
        case .typicalGap:
            let days = Set(completions.map(\.day)).sorted()

            return zip(days, days.dropFirst())
                .compactMap { calendar.dateComponents([.day], from: $0, to: $1).day }
                .map(Double.init)
                .median
        case let .typical(quantity):
            let values = values(of: quantity)
            return quantity.isClock ? values.map { Int($0) }.clockMedoid.map(Double.init) : values.median
        case let .total(quantity):
            return values(of: quantity).sum
        case let .maximum(quantity):
            return values(of: quantity).max()
        case let .share(part, whole):
            guard let whole = values(of: whole).sum, whole > 0 else {
                return nil
            }

            return (values(of: part).sum ?? 0) / whole
        case .latest, .mostFrequent:
            return nil
        }
    }

    public func reading(_ formula: Formula) -> Reading? {
        switch formula {
        case .latest:
            // The day it started on its own clock, like the rest of the app shows sessions.
            completions.max { ($0.date ?? .distantPast) < ($1.date ?? .distantPast) }.map { occurrence in
                .day(occurrence.session.startDate, calendar: occurrence.session.localCalendar(from: history.calendar))
            }
        case let .mostFrequent(pick):
            mostFrequent(pick)
        default:
            value(formula).flatMap { value in formula.unit(in: history).map { Reading(value, as: $0) } }
        }
    }

    private func values(of quantity: Quantity) -> [Double] {
        occurrences.compactMap { quantity.value(of: $0, in: history.calendar) }
    }

    private func mostFrequent(_ pick: Formula.Pick) -> Reading? {
        let title: String? = switch pick {
        case .workout:
            completions.mostFrequent { occurrence -> (key: Workout, date: Date)? in
                occurrence.session.workout.map { ($0, occurrence.date ?? .distantPast) }
            }?.title
        case .exercise:
            mostFrequentExercise(where: \.isCompleted)?.title
        case .skippedExercise:
            mostFrequentExercise(where: \.isSkipped)?.title
        }

        return title.map { .name($0) }
    }

    private func mostFrequentExercise(where status: (SessionEntry.Status) -> Bool) -> Exercise? {
        occurrences.flatMap(\.entries).filter { status($0.status) }.mostFrequent { entry -> (key: Exercise, date: Date)? in
            guard let exercise = entry.exercise, let date = entry.status.resolvedDate else {
                return nil
            }

            return (exercise, date)
        }
    }
}
