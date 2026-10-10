//
//  NumberFormat.swift
//  FormworkUI
//
//  Created by Daniel Wolbach on 10.10.26.
//

import Foundation

enum NumberFormat {
    case number(fractionLength: Int)
    case time
}

extension NumberFormat {
    var separator: String? {
        switch self {
        case let .number(fractionLength): fractionLength > 0 ? Locale.currentDecimalSeparator : nil
        case .time: ":"
        }
    }

    func format(_ value: Double) -> String {
        switch self {
        case let .number(fractionLength):
            value.formatted(.number.precision(.fractionLength(fractionLength)))
        case .time:
            Duration.seconds(value).formatted(.time(pattern: .minuteSecond).grouping(.never))
        }
    }

    func spokenFormat(_ value: Double) -> String {
        switch self {
        case .number: format(value)
        case .time: Duration.seconds(value).formatted(.units(allowed: [.minutes, .seconds], width: .wide))
        }
    }

    func parse(_ text: String) -> Double? {
        switch self {
        case .number:
            return try? Double(text, format: .number)
        case .time:
            let parts = text.split(separator: ":", omittingEmptySubsequences: false)
            let seconds = parts.count > 1 ? parts[1].padding(toLength: 2, withPad: "0", startingAt: 0) : "0"

            guard let minutes = parts[0].isEmpty ? 0 : Int(parts[0]), let seconds = Int(seconds) else {
                return nil
            }

            return Double(minutes * 60 + seconds)
        }
    }

    func accepts(_ text: String) -> Bool {
        guard let separator, let separatorRange = text.range(of: separator) else {
            return true
        }

        let fraction = text[separatorRange.upperBound...]

        switch self {
        case let .number(fractionLength): return fraction.count <= fractionLength
        case .time: return fraction.count <= 2 && (fraction.first ?? "0") <= "5"
        }
    }

    func pendingDigits(after text: String) -> String? {
        guard case .time = self, !text.isEmpty else {
            return nil
        }

        guard let separatorRange = text.range(of: ":") else {
            return ":00"
        }

        return String(repeating: "0", count: 2 - text[separatorRange.upperBound...].count)
    }
}
