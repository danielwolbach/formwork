//
//  Extensions.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 20.09.26.
//

import Foundation

extension FormatStyle where Self == Duration.UnitsFormatStyle {
    /// Whole minutes, dropping to seconds below one, so a set that took forty seconds doesn't read as no time.
    public static var exerciseDuration: Self {
        .units(allowed: [.minutes, .seconds], width: .abbreviated, maximumUnitCount: 1)
    }

    /// Hours and minutes: how long a session ran.
    public static var sessionDuration: Self {
        .units(allowed: [.hours, .minutes], width: .abbreviated)
    }
}

extension Calendar {
    /// Reads a date back on this calendar's own clock rather than the reader's, so a session recorded at 08:00
    /// still shows 08:00 in another time zone. A session reads its own dates back with `wallClockTime()`.
    public func formatStyle(date: Date.FormatStyle.DateStyle = .omitted, time: Date.FormatStyle.TimeStyle = .omitted) -> Date.FormatStyle {
        Date.FormatStyle(date: date, time: time, calendar: self, timeZone: timeZone)
    }
}

extension Int {
    fileprivate static let minutesPerDay = 24 * 60
}

extension [Int] {
    /// Of minutes since midnight, the one closest to all the others on a 24-hour clock, so it's always one of
    /// them and 23:30 and 00:30 are an hour apart rather than a day.
    var clockMedoid: Element? {
        sorted().min { distance(to: $0) < distance(to: $1) }
    }

    private func distance(to minute: Element) -> Element {
        reduce(0) { total, other in
            let delta = abs(other - minute)
            return total + Swift.min(delta, .minutesPerDay - delta)
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
