//
//  TypicalDuration.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import Foundation

/// The median duration of a session, or of an exercise when the subject is one or a slot of one.
struct TypicalDuration {
    /// In seconds.
    let value: Double?
}

extension TypicalDuration: Metric {
    init(_ window: History.Window) {
        let durations = switch window.history.subject {
        case .exercise, .entry: window.entries.filter(\.status.isCompleted).compactMap(\.duration)
        case .all, .workout: window.sessions.compactMap(\.duration)
        }

        self.value = durations.median
    }

    static var explanation: String {
        String(localized: ._Placeholder)
    }

    /// A median doesn't grow with the days it's taken over.
    static var tolerance: Double? {
        0.05
    }

    /// Round durations, in seconds: from a quarter minute for a quick exercise up to two hours for a session.
    static var axisSteps: [Double] {
        [15, 30, 60, 120, 300, 600, 900, 1800, 3600, 7200]
    }

    var pictogram: Pictogram {
        .duration
    }

    var title: String {
        String(localized: .statisticTypicalDurationTitle)
    }

    /// Seconds under a minute and whole minutes under an hour, like `exerciseDuration`; from an hour on, hours and
    /// minutes like a clock, e.g. 1:42. The hour is judged by the rounded minutes, so 59 min 50 sec reads as 1:00
    /// rather than 60 min.
    func label(for value: Double) -> String {
        let minutes = Duration.seconds((value / 60).rounded() * 60)
        return minutes < .seconds(3600) ? Duration.seconds(value).formatted(.exerciseDuration) : minutes.formatted(.time(pattern: .hourMinute))
    }
}
