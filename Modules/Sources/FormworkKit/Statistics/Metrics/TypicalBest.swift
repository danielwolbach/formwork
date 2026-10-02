//
//  TypicalBest.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

public struct TypicalBest {
    let target: ExerciseTarget?
}

extension TypicalBest: Metric {
    public init(_ window: History.Window) {
        let ranked = Progression.bests(in: window).map(\.target).sorted { $0.rank < $1.rank }
        self.target = ranked.isEmpty ? nil : ranked[(ranked.count - 1) / 2]
    }

    public static var info: String {
        String(localized: .statisticTypicalBestInfo)
    }

    public static var pictogram: Pictogram {
        .progression
    }

    public static var title: String {
        String(localized: .statisticTypicalBestTitle)
    }

    public static var tolerance: Double? {
        0.02
    }

    public var value: Double? {
        target?.rank
    }

    public func reading(of value: Double) -> Reading {
        Reading(rank: value, of: target?.exerciseKind)
    }
}
