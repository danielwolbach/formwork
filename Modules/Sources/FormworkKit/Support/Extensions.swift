//
//  Extensions.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 20.09.26.
//

import Foundation

extension Calendar {
    public func formatStyle(date: Date.FormatStyle.DateStyle? = nil, time: Date.FormatStyle.TimeStyle? = nil) -> Date.FormatStyle {
        Date.FormatStyle(date: date, time: time, calendar: self, timeZone: timeZone)
    }
}

extension [Int] {
    public var clockMedoid: Element? {
        sorted().min { distance(to: $0) < distance(to: $1) }
    }

    private func distance(to minute: Element) -> Element {
        reduce(0) { total, other in
            let delta = abs(other - minute)
            return total + Swift.min(delta, 24 * 60 - delta)
        }
    }
}

extension [Double] {
    var median: Double? {
        guard !isEmpty else {
            return nil
        }

        let sorted = sorted(), middle = count / 2
        return count.isMultiple(of: 2) ? (sorted[middle - 1] + sorted[middle]) / 2 : sorted[middle]
    }
}
