//
//  TypicalBest.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

public struct TypicalBest {
    let target: ExerciseTarget?

    let unitSystem: UnitSystem
}

extension TypicalBest: Metric {
    public typealias Format = TargetFormat

    public init(_ window: History.Window) {
        let ranked = Progression.bests(in: window).map(\.target).sorted { $0.rank < $1.rank }
        self.target = ranked.isEmpty ? nil : ranked[(ranked.count - 1) / 2]
        self.unitSystem = .current
    }

    public static var info: String {
        String(localized: .statisticTypicalBestInfo)
    }

    public static var tolerance: Double? {
        0.02
    }

    public var pictogram: Pictogram {
        .progression
    }

    public var title: String {
        String(localized: .statisticTypicalBestTitle)
    }

    public var value: Double? {
        target?.rank
    }

    public var format: Format {
        TargetFormat(kind: target?.exerciseKind, system: unitSystem)
    }
}
