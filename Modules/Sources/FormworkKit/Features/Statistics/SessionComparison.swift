//
//  SessionComparison.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 02.10.26.
//

import Foundation

public struct SessionComparison {
    public struct Point: Identifiable {
        public let id: Int

        public let date: Date

        public let value: Double?

        public let isCurrent: Bool
    }

    public let kind: SessionFigureKind

    public let session: Session

    public let current: Reading?

    public let baseline: Reading?

    public let direction: Trend.Direction?

    let window: History.Window?

    public init(_ kind: SessionFigureKind, of session: Session, among sessions: [Session], calendar: Calendar = .current) {
        self.kind = kind
        self.session = session
        self.current = kind.reading(of: session, calendar: calendar)

        guard
            let workout = session.workout,
            let day = session.period(of: .day, in: calendar)?.start,
            let before = calendar.date(byAdding: .day, value: -1, to: day)
        else {
            self.baseline = nil
            self.direction = nil
            self.window = nil
            return
        }

        let history = History(.workout(workout), among: sessions, at: day, calendar: calendar)
        let window = history.days(History.recentDays, endingOn: before)
        switch kind.definition.value {
        case let .measure(unit, tolerance, value):
            let values = window.sessions.compactMap(value)
            let typical = values.count < History.minimumValues ? nil : values.median

            self.baseline = typical.map { Reading($0, as: unit) }
            self.direction = Trend.Direction(from: typical, to: value(session), tolerance: tolerance)
        case let .clock(minute):
            let minutes = window.sessions.compactMap { minute($0, calendar) }

            self.baseline = minutes.count < History.minimumValues ? nil : minutes.clockMedoid.flatMap { Reading(minuteOfDay: $0, in: calendar) }
            self.direction = nil
        }

        self.window = window
    }
}

extension SessionComparison {
    public func points(count: Int = History.chartedSessions) -> [Point] {
        guard case let .measure(_, _, value) = kind.definition.value else {
            return []
        }

        let sessions = (window?.history.sessions ?? [session])
            .filter { $0.startDate <= session.startDate }
            .sorted { $0.startDate < $1.startDate }
            .suffix(count)

        return sessions.enumerated().map { index, other in
            Point(
                id: index,
                date: other.startDate,
                value: value(other),
                isCurrent: other === session
            )
        }
    }
}
