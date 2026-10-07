//
//  SessionProgressFormat.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 07.10.26.
//

import Foundation

public struct SessionProgressFormat: FormatStyle {
    let now: Date

    public init(at now: Date = .now) {
        self.now = now
    }

    public func format(_ session: Session) -> String {
        let pending = String(localized: .formatPendingCountScheme(count: session.pendingEntries.count))
        let finish = session.workout.flatMap { workout in
            History(.workout(workout), among: workout.sessions ?? [], at: now).recent.typicalDuration
                .map { session.startDate.addingTimeInterval($0) }
                .flatMap { $0 > now ? "→ " + $0.formatted(Calendar.current.formatStyle(time: .shortened)) : nil }
        }

        return [pending, finish].compactMap(\.self).joined(separator: " ")
    }
}

extension FormatStyle where Self == SessionProgressFormat {
    public static var sessionProgress: SessionProgressFormat {
        SessionProgressFormat()
    }
}

extension Session {
    public func formatted<Style: FormatStyle>(_ style: Style) -> Style.FormatOutput where Style.FormatInput == Session {
        style.format(self)
    }
}
