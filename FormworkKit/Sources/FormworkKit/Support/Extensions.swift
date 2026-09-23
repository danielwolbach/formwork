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

/// The periods statistics are read over. Whole days in their calendar, as `Session.falls(into:in:)` needs.
extension DateInterval {
    public static let allTime = DateInterval(start: .distantPast, end: .distantFuture)

    public static func month(_ month: Int, year: Int? = nil, calendar: Calendar = .current) -> Self {
        precondition((1 ... 12).contains(month), "Month must be between 1 and 12.")
        return period(.month, of: DateComponents(year: year ?? calendar.component(.year, from: .now), month: month), calendar: calendar)
    }

    public static func year(_ year: Int? = nil, calendar: Calendar = .current) -> Self {
        period(.year, of: DateComponents(year: year ?? calendar.component(.year, from: .now)), calendar: calendar)
    }

    private static func period(_ component: Calendar.Component, of components: DateComponents, calendar: Calendar) -> Self {
        guard let date = calendar.date(from: components), let interval = calendar.dateInterval(of: component, for: date) else {
            preconditionFailure("No \(component) for \(components).")
        }
        return interval
    }
}
