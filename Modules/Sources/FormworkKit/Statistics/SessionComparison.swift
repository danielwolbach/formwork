//
//  SessionComparison.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 02.10.26.
//

import Foundation

public struct SessionComparison<S: SessionFigure> {
    public struct Point: Identifiable {
        public let id: Int

        public let date: Date

        public let figure: S

        public let isCurrent: Bool

        public let isBaseline: Bool
    }

    public let current: S

    public let baseline: S?

    public let session: Session

    let calendar: Calendar

    let window: History.Window?

    /// The baseline is the workout's sessions in the days before the session's day, so it never includes the
    /// session itself and stays meaningful for sessions long past.
    public init(_ session: Session, among sessions: [Session], calendar: Calendar = .current) {
        self.current = S(session, calendar: calendar)
        self.session = session
        self.calendar = calendar

        guard
            let workout = session.workout,
            let day = session.period(of: .day, in: calendar)?.start,
            let before = calendar.date(byAdding: .day, value: -1, to: day)
        else {
            self.baseline = nil
            self.window = nil
            return
        }

        let history = History(.workout(workout), among: sessions, at: day, calendar: calendar)
        let window = history.days(History.recentDays, endingOn: before)

        self.baseline = window.sessions.count < History.minimumSessions ? nil : S(typicalOf: window.sessions, calendar: calendar)
        self.window = window
    }
}

extension SessionComparison where S: SessionMeasure {
    public var direction: Direction? {
        S.tolerance.flatMap { Direction(from: baseline?.value, to: current.value, tolerance: $0) }
    }
}

extension SessionComparison {
    /// The workout's sessions up to and including this one, oldest first.
    public func points(count: Int = 20) -> [Point] {
        let sessions = (window?.history.sessions ?? [session])
            .filter { $0.startDate <= session.startDate }
            .sorted { $0.startDate < $1.startDate }
            .suffix(count)
        let baseline = window?.sessions ?? []

        return sessions.enumerated().map { index, other in
            Point(
                id: index,
                date: other.startDate,
                figure: S(other, calendar: calendar),
                isCurrent: other === session,
                isBaseline: baseline.contains { $0 === other }
            )
        }
    }
}
