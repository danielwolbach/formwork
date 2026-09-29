//
//  LastCompleted.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import Foundation

public struct LastCompleted {
    public let date: Date?

    public let session: Session?

    public let calendar: Calendar
}

extension LastCompleted: Statistic {
    public init(_ window: History.Window) {
        let calendar = window.history.calendar

        switch window.history.subject {
        case .exercise, .entry:
            let last = window.entries
                .filter(\.status.isCompleted)
                .max { ($0.status.resolvedDate ?? .distantPast) < ($1.status.resolvedDate ?? .distantPast) }
            self.init(date: last?.status.resolvedDate, session: last?.session, calendar: calendar)
        case .all, .workout:
            let last = window.sessions.max { ($0.endDate ?? .distantPast) < ($1.endDate ?? .distantPast) }
            self.init(date: last?.endDate, session: last, calendar: calendar)
        }
    }

    public static var info: String {
        String(localized: .statisticLastCompletedInfo)
    }

    public var pictogram: Pictogram {
        .date
    }

    public var title: String {
        String(localized: .statisticLastCompletedTitle)
    }

    public var formattedValue: String? {
        guard let date else {
            return nil
        }

        guard let weekAgo = calendar.date(byAdding: .day, value: -7, to: .now), date < weekAgo else {
            var style = Date.RelativeFormatStyle(presentation: .named, calendar: calendar, capitalizationContext: .beginningOfSentence)
            style.allowedFields = [.day]
            return date.formatted(style)
        }

        let local = session?.localCalendar(from: calendar) ?? calendar
        let day = session?.startDate ?? date
        let style = local.formatStyle().day().month()
        return local.isDate(day, equalTo: .now, toGranularity: .year) ? day.formatted(style) : day.formatted(style.year())
    }
}
