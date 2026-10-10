//
//  Occurrence.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 10.10.26.
//

import Foundation

public struct Occurrence {
    public let session: Session

    public let entry: SessionEntry?

    public let day: Date

    public let date: Date?

    init(_ session: Session, entry: SessionEntry? = nil, in calendar: Calendar) {
        self.session = session
        self.entry = entry
        self.day = session.period(of: .day, in: calendar)?.start ?? calendar.startOfDay(for: session.startDate)
        self.date = if let entry {
            entry.status.isCompleted ? entry.status.resolvedDate : nil
        } else {
            session.isActive ? nil : session.endDate
        }
    }
}

extension Occurrence {
    public var isCompleted: Bool {
        date != nil
    }

    public var entries: [SessionEntry] {
        entry.map { [$0] } ?? session.entries ?? []
    }

    var duration: TimeInterval? {
        guard isCompleted else {
            return nil
        }

        return entry.map(\.duration) ?? session.duration
    }
}
