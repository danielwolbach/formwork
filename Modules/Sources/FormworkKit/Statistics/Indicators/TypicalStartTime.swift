//
//  TypicalStartTime.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import Foundation

public struct TypicalStartTime {
    public let time: DateComponents?

    public let calendar: Calendar
}

extension TypicalStartTime: Indicator {
    public init(_ window: History.Window) {
        let calendar = window.history.calendar
        let minute = window.sessions.compactMap { $0.startMinute(in: calendar) }.clockMedoid

        self.init(time: minute.map { DateComponents(hour: $0 / 60, minute: $0 % 60) }, calendar: calendar)
    }

    public static var info: String {
        String(localized: .statisticTypicalStartTimeInfo)
    }

    public var pictogram: Pictogram {
        .time
    }

    public var title: String {
        String(localized: .statisticTypicalStartTimeTitle)
    }

    public var reading: Reading? {
        time.flatMap { calendar.date(from: $0) }.map { .time($0, calendar: calendar) }
    }
}
