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

extension Sequence {
    func mostFrequent<Key: Hashable>(by occurrence: (Element) -> (key: Key, date: Date)?) -> Key? {
        let tally = reduce(into: [Key: (count: Int, latest: Date)]()) { tally, element in
            guard let seen = occurrence(element) else {
                return
            }

            let current = tally[seen.key] ?? (0, .distantPast)
            tally[seen.key] = (current.count + 1, Swift.max(current.latest, seen.date))
        }

        return tally.max { ($0.value.count, $0.value.latest) < ($1.value.count, $1.value.latest) }?.key
    }
}
