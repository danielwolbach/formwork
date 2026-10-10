//
//  Series.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import Foundation

public struct Series {
    public struct Point: Identifiable {
        public let id: Int

        public let date: Date

        public let value: Double?

        public let isHighlighted: Bool

        public let isCarried: Bool
    }

    public let span: DateInterval

    public let unit: Reading.Unit

    public let points: [Point]

    init(span: DateInterval, unit: Reading.Unit, values: [(date: Date, value: Double?)], highlighted: Date? = nil, carried: Double? = nil) {
        let carried = carried.map { [(date: span.start, value: Optional($0))] } ?? []

        self.span = span
        self.unit = unit
        self.points = (carried + values).enumerated().map { index, point in
            Point(id: index, date: point.date, value: point.value, isHighlighted: point.date == highlighted, isCarried: index < carried.count)
        }
    }
}

extension Series {
    public init?(_ quantity: Quantity, endingWith session: Session, among sessions: [Session], count: Int = History.chartedSessions, calendar: Calendar = .current) {
        guard !quantity.isClock else {
            return nil
        }

        let history = Comparison.before(session, among: sessions, calendar: calendar)?.history
        let occurrences = (history?.occurrences ?? [Occurrence(session, in: calendar)])
            .filter { $0.session.startDate <= session.startDate }
            .sorted { $0.session.startDate < $1.session.startDate }
            .suffix(count)
        let dates = occurrences.map(\.session.startDate)

        self.init(
            span: DateInterval(start: dates.first ?? session.startDate, end: dates.last ?? session.startDate),
            unit: quantity.unit(of: nil, in: calendar),
            values: occurrences.map { ($0.session.startDate, quantity.value(of: $0, in: calendar)) },
            highlighted: session.startDate
        )
    }

    public var values: [Double] {
        points.compactMap(\.value)
    }

    public func reading(of value: Double) -> Reading {
        Reading(value, as: unit)
    }
}

extension History {
    public func series(_ formula: Formula) -> Series? {
        guard formula.isPerOccurrence, formula.isNumeric, let unit = formula.unit(in: self) else {
            return nil
        }

        let period = days(Self.chartedWeeks * 7, endingOn: now)
        let values = period.occurrences
            .sorted { $0.session.startDate < $1.session.startDate }
            .compactMap { occurrence in formula.value(of: occurrence, in: calendar).map { (occurrence.session.startDate, Optional($0)) } }

        return Series(span: period.span, unit: unit, values: values)
    }

    public func monthly(_ formula: Formula, in year: Int) -> Series? {
        guard formula.isNumeric, let unit = formula.unit(in: self) else {
            return nil
        }

        let months = months(in: year).filter(\.isOnRecord)
        return Series(span: self.year(year).span, unit: unit, values: months.map { ($0.span.start, $0.value(formula)) })
    }
}
