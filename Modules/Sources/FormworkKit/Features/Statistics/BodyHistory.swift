//
//  BodyHistory.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 10.10.26.
//

import Foundation

public struct BodyHistory {
    let history: History
}

extension History {
    public var body: BodyHistory {
        BodyHistory(history: self)
    }
}

extension BodyHistory {
    public func latest(_ measurement: BodyMeasurement) -> BodyMeasurement.Sample? {
        samples(of: measurement).last { $0.date < history.interval.end }
    }

    public func comparison(_ measurement: BodyMeasurement, tolerance: Double) -> Comparison {
        let current = latest(measurement)?.value
        let typical = carried(measurement, over: history.baseline.span).median

        return Comparison(
            current: current.map { Reading($0, as: measurement.unit) },
            typical: typical.map { Reading($0, as: measurement.unit) },
            direction: Comparison.Direction(from: typical, to: current, tolerance: tolerance)
        )
    }

    public func series(_ measurement: BodyMeasurement) -> Series {
        let span = history.days(History.chartedWeeks * 7, endingOn: history.now).span

        return Series(
            span: span,
            unit: measurement.unit,
            values: samples(of: measurement, in: span).map { ($0.date, $0.value) },
            carried: samples(of: measurement).last { $0.date < span.start }?.value
        )
    }

    public func monthly(_ measurement: BodyMeasurement, in year: Int) -> Series {
        let months = history.months(in: year).filter { $0.span.start < history.interval.end }

        return Series(
            span: history.year(year).span,
            unit: measurement.unit,
            values: months.map { ($0.span.start, samples(of: measurement, in: $0.span).map(\.value).median) }
        )
    }

    public func years(of measurement: BodyMeasurement) -> ClosedRange<Int>? {
        let current = history.years.upperBound
        return samples(of: measurement).first.map { min(history.calendar.component(.year, from: $0.date), current) ... current }
    }

    private func samples(of measurement: BodyMeasurement) -> [BodyMeasurement.Sample] {
        history.measurements[measurement] ?? []
    }

    private func samples(of measurement: BodyMeasurement, in span: DateInterval) -> [BodyMeasurement.Sample] {
        let end = min(span.end, history.interval.end)
        return samples(of: measurement).filter { span.start <= $0.date && $0.date < end }
    }

    private func carried(_ measurement: BodyMeasurement, over span: DateInterval) -> [Double] {
        let calendar = history.calendar
        let samples = samples(of: measurement)
        let ends = sequence(first: span.start) { calendar.date(byAdding: .day, value: 1, to: $0) }
            .dropFirst()
            .prefix { $0 <= min(span.end, history.interval.end) }

        return ends.compactMap { end in samples.last { $0.date < end }?.value }
    }
}
