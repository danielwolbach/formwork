//
//  Reading.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 29.09.26.
//

import Foundation

public enum Reading: Hashable, Sendable {
    case count(Int)
    case percent(Double)
    case rate(Double)
    case weight(kilograms: Double)
    case distance(meters: Double)
    case duration(seconds: Double)
    case days(Double)
    case heartRate(beatsPerMinute: Double)
    case reps(Int)
    case name(String)
    case day(Date, calendar: Calendar)
    case time(Date, calendar: Calendar)

    /// How a plain number reads.
    public enum Unit: Sendable {
        case count
        case percent
        case rate
        case weight
        case duration
        case days
        case heartRate
        /// A target's rank, read in an exercise's kind.
        case rank(Exercise.Kind?)
        /// Minutes since midnight.
        case time(Calendar)
    }
}

extension Reading {
    public init(rank: Double, of kind: Exercise.Kind?) {
        self = switch kind {
        case .weight: .weight(kilograms: rank)
        case .bodyweight: .reps(Int(rank.rounded()))
        case .duration: .duration(seconds: rank)
        case .distance: .distance(meters: rank)
        case nil: .count(Int(rank.rounded()))
        }
    }

    init(_ value: Double, as unit: Unit) {
        self = switch unit {
        case .count: .count(Int(value.rounded()))
        case .percent: .percent(value)
        case .rate: .rate(value)
        case .weight: .weight(kilograms: value)
        case .duration: .duration(seconds: value)
        case .days: .days(value)
        case .heartRate: .heartRate(beatsPerMinute: value)
        case let .rank(kind): Reading(rank: value, of: kind)
        case let .time(calendar): .time(calendar.date(from: DateComponents(hour: Int(value) / 60, minute: Int(value) % 60)) ?? .distantPast, calendar: calendar)
        }
    }
}
