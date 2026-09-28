//
//  Extensions.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 20.09.26.
//

import SwiftUI

extension FormatStyle where Self == Duration.UnitsFormatStyle {
    public static var sessionDuration: Self {
        .units(allowed: [.hours, .minutes], width: .abbreviated)
    }
}

extension View {
    public func card(_ style: some ShapeStyle) -> some View {
        background(style)
            .clipShape(.rect(cornerRadius: 16, style: .continuous))
    }

    public func card() -> some View {
        card(.ultraThinMaterial)
    }
}

extension Locale {
    public static var currentDecimalSeparator: String {
        current.decimalSeparator ?? "."
    }
}

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
