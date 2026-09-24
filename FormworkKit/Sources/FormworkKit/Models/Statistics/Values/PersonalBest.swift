//
//  PersonalBest.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import Foundation

/// The best completed target of the exercise's current type. Only means something for an exercise.
struct PersonalBest {
    let target: ExerciseTarget?
}

extension PersonalBest: Metric {
    init(_ window: History.Window) {
        self.target = Progression.bests(in: window).map(\.target).max { $0.rank < $1.rank }
    }

    static var explanation: String {
        String(localized: ._Placeholder)
    }

    /// A best only ever grows with the days it's taken over.
    static var tolerance: Double? {
        nil
    }

    var pictogram: Pictogram {
        .record
    }

    var title: String {
        String(localized: .statisticPersonalBestTitle)
    }

    var subtitle: String? {
        target?.formattedRank
    }

    var value: Double? {
        target?.rank
    }

    func label(for value: Double) -> String {
        target?.label(for: value) ?? value.formatted()
    }
}
