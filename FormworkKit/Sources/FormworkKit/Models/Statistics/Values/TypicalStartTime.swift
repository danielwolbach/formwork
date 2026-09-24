//
//  TypicalStartTime.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import Foundation

/// The time of day a session was typically started at: the recorded start time closest to all the others on
/// the clock, so it's always one that was actually trained at.
struct TypicalStartTime {
    /// Hour and minute, by the clock the sessions were recorded on.
    let time: DateComponents?

    let calendar: Calendar
}

extension TypicalStartTime: Statistic {
    init(_ window: History.Window) {
        let calendar = window.history.calendar
        let minute = window.sessions.compactMap { $0.startMinute(in: calendar) }.clockMedoid

        self.init(time: minute.map { DateComponents(hour: $0 / 60, minute: $0 % 60) }, calendar: calendar)
    }

    static var explanation: String {
        String(localized: ._Placeholder)
    }

    var pictogram: Pictogram {
        .time
    }

    var title: String {
        String(localized: .statisticTypicalStartTimeTitle)
    }

    var subtitle: String? {
        time.flatMap { calendar.date(from: $0) }?.formatted(calendar.formatStyle(time: .shortened))
    }
}
