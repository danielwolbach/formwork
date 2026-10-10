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
        case let .weight(kilograms): weight(kilograms)
        case let .distance(meters): distance(meters)
        case let .duration(seconds): DurationFormat().format(seconds)
        case let .days(days): IntervalFormat().format(days)
        case let .heartRate(beatsPerMinute): HeartRateFormat().format(beatsPerMinute)
        case let .reps(reps): String(localized: .exerciseTargetBodyweightRank(count: reps))
        case let .name(name): name
        case let .day(date, calendar): day(date, in: calendar)
        case let .time(date, calendar): date.formatted(calendar.formatStyle(time: .shortened))
        }
    }

    private func weight(_ kilograms: Double) -> String {
        Measurement(value: kilograms, unit: UnitMass.kilograms)
            .converted(to: units.weightUnit)
            .formatted(.measurement(width: .abbreviated, usage: .asProvided, numberFormatStyle: .number.precision(.fractionLength(0 ... 1))))
    }

    private func distance(_ meters: Double) -> String {
        let unit = units.distance == .metric && meters < 1000 ? UnitLength.meters : units.distanceUnit

        return Measurement(value: meters, unit: UnitLength.meters)
            .converted(to: unit)
            .formatted(.measurement(width: .abbreviated, usage: .asProvided, numberFormatStyle: .number.precision(.fractionLength(0 ... 2))))
    }

    private func day(_ date: Date, in calendar: Calendar) -> String {
        guard let weekAgo = calendar.date(byAdding: .day, value: -7, to: .now), date < weekAgo else {
            var style = Date.RelativeFormatStyle(presentation: .named, calendar: calendar, capitalizationContext: .beginningOfSentence)
            style.allowedFields = [.day]
            return date.formatted(style)
        }

        let style = calendar.formatStyle().day().month()
        return calendar.isDate(date, equalTo: .now, toGranularity: .year) ? date.formatted(style) : date.formatted(style.year())
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
