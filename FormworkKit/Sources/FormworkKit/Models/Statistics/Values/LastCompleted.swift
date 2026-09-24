//
//  LastCompleted.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import Foundation

/// When the most recent session ended, or when the exercise was last completed when that's the subject. A date
/// rather than a number, so there's nothing to compare or chart.
struct LastCompleted {
    let date: Date?

    /// The session it happened in, whose clock the day is read on.
    let session: Session?

    let calendar: Calendar
}

extension LastCompleted: Statistic {
    init(_ window: History.Window) {
        let calendar = window.history.calendar

        switch window.history.subject {
        case .exercise:
            let last = window.entries
                .filter(\.status.isCompleted)
                .max { ($0.status.resolved ?? .distantPast) < ($1.status.resolved ?? .distantPast) }
            self.init(date: last?.status.resolved, session: last?.session, calendar: calendar)
        case .all, .workout:
            let last = window.sessions.max { ($0.ended ?? .distantPast) < ($1.ended ?? .distantPast) }
            self.init(date: last?.ended, session: last, calendar: calendar)
        }
    }

    static var explanation: String {
        String(localized: ._Placeholder)
    }

    var pictogram: Pictogram {
        .date
    }

    var title: String {
        String(localized: .statisticLastCompletedTitle)
    }

    /// Within a week, the day relative to today; before that, the day the session started on, by its own clock.
    var subtitle: String? {
        guard let date else {
            return nil
        }

        guard let weekAgo = calendar.date(byAdding: .day, value: -7, to: .now), date < weekAgo else {
            var style = Date.RelativeFormatStyle(presentation: .named, calendar: calendar, capitalizationContext: .beginningOfSentence)
            style.allowedFields = [.day]
            return date.formatted(style)
        }

        let local = session?.localCalendar(from: calendar) ?? calendar
        let day = session?.started ?? date
        let style = local.formatStyle().day().month()
        return local.isDate(day, equalTo: .now, toGranularity: .year) ? day.formatted(style) : day.formatted(style.year())
    }
}
