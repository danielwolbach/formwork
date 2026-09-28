//
//  PersonalBest.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

public struct PersonalBest {
    let target: ExerciseTarget?

    let unitSystem: UnitSystem
}

extension PersonalBest: Metric {
    public typealias Format = TargetFormat

    public init(_ window: History.Window) {
        self.target = Progression.bests(in: window).map(\.target).max { $0.rank < $1.rank }
        self.unitSystem = .current
    }

    public static var explanation: String {
        String(localized: .placeholder)
    }

    /// A best only ever grows with the days it's taken over.
    public static var tolerance: Double? {
        nil
    }

    public var pictogram: Pictogram {
        .record
    }

    public var title: String {
        String(localized: .statisticPersonalBestTitle)
    }

    public var value: Double? {
        target?.rank
    }

    public var format: Format {
        TargetFormat(kind: target?.exerciseKind, system: unitSystem)
    }
}
