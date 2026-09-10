//
//  Extensions.swift
//  Formwork
//
//  Created by Daniel Wolbach on 05.09.26.
//

import SwiftUI

extension Binding where Value == String {
    func animated() -> Binding<String> {
        Binding(
            get: { wrappedValue },
            set: { newValue in withAnimation(.snappy) { wrappedValue = newValue } }
        )
    }
}

extension Date {
    func relativeDayDescription(now: Date = .now) -> String {
        let calendar = Calendar.autoupdatingCurrent

        let days = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: self),
            to: calendar.startOfDay(for: now)
        ).day ?? 0

        switch days {
        case 0:
            return String(localized: .dateTodayTitle)
        case 1 ... 6:
            let shifted = calendar.date(byAdding: .day, value: -days, to: now) ?? self
            return shifted.formatted(.relative(presentation: .named))
        default:
            return formatted(.dateTime.day().month(.abbreviated))
        }
    }
}

extension Date {
    func monthDescription(now: Date = .now) -> String {
        let calendar = Calendar.autoupdatingCurrent

        if calendar.component(.year, from: self) == calendar.component(.year, from: now) {
            return formatted(.dateTime.month(.wide))
        }

        return formatted(.dateTime.month(.wide).year())
    }
}

extension Calendar {
    nonisolated func weekStart(for date: Date) -> Date? {
        dateInterval(of: .weekOfYear, for: date)?.start
    }
}

extension GridItem {
    static func ntile(n: Int, spacing: CGFloat? = nil) -> [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: spacing), count: n)
    }
}

extension Locale {
    /// The decimal separator to both show on the keypad and parse back out.
    static var currentDecimalSeparator: String {
        current.decimalSeparator ?? "."
    }
}
