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
    func defaultFormattedRelative(now: Date = .now) -> String {
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
    
    func defaultFormattedTime() -> String {
        formatted(.dateTime.hour().minute())
    }
}

extension Duration {
    func defaultFormatted() -> String {
        formatted(.units(
            allowed: [.hours, .minutes],
            width: .abbreviated
        ))
    }
}

extension Double {
    func defaultFormattedPercent() -> String {
        formatted(.percent.precision(.fractionLength(0)))
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

extension GridItem {
    static func ntile(n: Int, spacing: CGFloat? = nil) -> [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: spacing), count: n)
    }
}

extension Locale {
    static var currentDecimalSeparator: String {
        current.decimalSeparator ?? "."
    }
}
