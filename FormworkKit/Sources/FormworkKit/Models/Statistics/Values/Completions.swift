//
//  Completions.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import Foundation

/// How many sessions were finished, or how often the exercise was completed when that's the subject.
struct Completions {
    let count: Int
}

extension Completions: Metric {
    init(_ window: History.Window) {
        self.count = switch window.history.subject {
        case .exercise: window.entries.count(where: \.status.isCompleted)
        case .all, .workout: window.sessions.count
        }
    }

    static var explanation: String {
        String(localized: ._Placeholder)
    }

    /// A count grows with the days it's taken over, so four weeks would always look worse than twelve.
    static var tolerance: Double? {
        nil
    }

    var pictogram: Pictogram {
        .tally
    }

    var title: String {
        String(localized: .statisticCompletionsTitle)
    }

    var value: Double? {
        Double(count)
    }

    func label(for value: Double) -> String {
        Int(value).formatted()
    }
}
