//
//  Habits.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 04.10.26.
//

import Foundation

extension History.Window {
    var lastCompletion: History.Completion? {
        completions.max { $0.date < $1.date }
    }

    var completionCount: Int {
        completions.count
    }

    var completionRate: Double? {
        entries.isEmpty ? nil : Double(entries.count(where: \.status.isCompleted)) / Double(entries.count)
    }

    var weeklySessions: Double? {
        lengthInWeeks.map { Double(sessions.count) / $0 }
    }

    var typicalDuration: Double? {
        completions.compactMap(\.duration).median
    }

    var typicalStartTime: Int? {
        sessions.compactMap { $0.startMinute(in: history.calendar) }.clockMedoid
    }

    var typicalInterval: Double? {
        let calendar = history.calendar
        let days = Set(completions.compactMap { $0.session.period(of: .day, in: calendar)?.start }).sorted()

        return zip(days, days.dropFirst())
            .compactMap { calendar.dateComponents([.day], from: $0, to: $1).day }
            .map(Double.init)
            .median
    }

    fileprivate var lengthInWeeks: Double? {
        guard let days = history.calendar.dateComponents([.day], from: interval.start, to: interval.end).day, days > 0 else {
            return nil
        }

        return Double(max(days, 7)) / 7
    }
}
