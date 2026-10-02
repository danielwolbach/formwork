//
//  SessionEndTime.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 02.10.26.
//

import Foundation

public struct SessionEndTime {
    public let time: DateComponents?

    public let calendar: Calendar
}

extension SessionEndTime: SessionFigure {
    public init(_ session: Session, calendar: Calendar) {
        let local = session.localCalendar(from: calendar)

        self.init(time: session.endMinute(in: local).map(Self.time(of:)), calendar: local)
    }

    public init(typicalOf sessions: [Session], calendar: Calendar) {
        self.init(time: sessions.compactMap { $0.endMinute(in: calendar) }.clockMedoid.map(Self.time(of:)), calendar: calendar)
    }

    public static var info: String {
        String(localized: .placeholder)
    }

    public static var pictogram: Pictogram {
        .time
    }

    public static var title: String {
        String(localized: .placeholder)
    }

    public var reading: Reading? {
        time.flatMap { calendar.date(from: $0) }.map { .time($0, calendar: calendar) }
    }

    private static func time(of minute: Int) -> DateComponents {
        DateComponents(hour: minute / 60, minute: minute % 60)
    }
}
