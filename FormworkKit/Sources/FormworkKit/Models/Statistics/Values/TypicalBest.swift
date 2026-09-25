//
//  TypicalBest.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import Foundation

/// The typical day's best: of the best completed target on each day, the one in the middle by rank, a target
/// actually done. Unlike the personal best, it can go down. Only means something for an exercise or a slot of one.
struct TypicalBest {
    let target: ExerciseTarget?
}

extension TypicalBest: Metric {
    init(_ window: History.Window) {
        let ranked = Progression.bests(in: window).map(\.target).sorted { $0.rank < $1.rank }
        self.target = ranked.isEmpty ? nil : ranked[(ranked.count - 1) / 2]
    }

    static var explanation: String {
        String(localized: ._Placeholder)
    }

    static var tolerance: Double? {
        0.02
    }

    var pictogram: Pictogram {
        .progression
    }

    var title: String {
        String(localized: .statisticTypicalBestTitle)
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
