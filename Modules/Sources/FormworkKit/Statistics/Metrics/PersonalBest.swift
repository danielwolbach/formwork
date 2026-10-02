//
//  PersonalBest.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

public struct PersonalBest {
    let target: ExerciseTarget?
}

extension PersonalBest: Metric {
    public init(_ window: History.Window) {
        self.target = Progression.bests(in: window).map(\.target).max { $0.rank < $1.rank }
    }

    public static var info: String {
        String(localized: .statisticPersonalBestInfo)
    }

    public static var pictogram: Pictogram {
        .record
    }

    public static var title: String {
        String(localized: .statisticPersonalBestTitle)
    }

    public static var tolerance: Double? {
        nil
    }

    public var value: Double? {
        target?.rank
    }

    public func reading(of value: Double) -> Reading {
        Reading(rank: value, of: target?.exerciseKind)
    }
}
