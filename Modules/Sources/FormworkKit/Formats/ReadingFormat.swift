//
//  ReadingFormat.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 29.09.26.
//

import Foundation

public struct ReadingFormat: FormatStyle {
    let units: Units

    public init(units: Units) {
        self.units = units
    }

    public func format(_ reading: Reading) -> String {
        switch reading {
        case let .count(count): count.formatted()
        case let .percent(fraction): fraction.formatted(.percent.precision(.fractionLength(0)))
        case let .rate(rate): rate.formatted(.number.precision(.fractionLength(1)))
        case let .weight(kilograms): WeightFormat(units: units).format(kilograms)
        case let .distance(meters): DistanceFormat(units: units).format(meters)
        case let .duration(seconds): DurationFormat().format(seconds)
        case let .days(days): IntervalFormat().format(days)
        case let .heartRate(beatsPerMinute): HeartRateFormat().format(beatsPerMinute)
        case let .reps(reps): RepsFormat().format(reps)
        case let .name(name): name
        case let .day(date, calendar): DayFormat(calendar: calendar).format(date)
        case let .time(date, calendar): date.formatted(calendar.formatStyle(time: .shortened))
        }
    }
}

extension FormatStyle where Self == ReadingFormat {
    public static func reading(units: Units) -> ReadingFormat {
        ReadingFormat(units: units)
    }
}

extension Reading {
    public func formatted<Style: FormatStyle>(_ style: Style) -> Style.FormatOutput where Style.FormatInput == Self {
        style.format(self)
    }
}
