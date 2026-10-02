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

extension LastCompleted: Indicator {
    public init(_ window: History.Window) {
        let last = window.completions.max { $0.date < $1.date }

        self.init(date: last?.date, session: last?.session, calendar: window.history.calendar)
    }

    public static var info: String {
        String(localized: .statisticLastCompletedInfo)
    }

    public static var pictogram: Pictogram {
        .date
    }

    public static var title: String {
        String(localized: .statisticLastCompletedTitle)
    }

    public var reading: Reading? {
        guard let date else {
            return nil
        }

        // The day it started on its own clock, like the rest of the app shows sessions.
        let local = session?.localCalendar(from: calendar) ?? calendar
        return .day(session?.startDate ?? date, calendar: local)
    }
}
