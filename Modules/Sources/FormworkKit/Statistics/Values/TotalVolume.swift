//
//  TotalVolume.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 28.09.26.
//

import Foundation

public struct TotalVolume {
    public let kilograms: Double?

    public let unitSystem: UnitSystem
}

extension TotalVolume: Metric {
    public typealias Format = VolumeFormat

    public init(_ window: History.Window) {
        let volume = window.entries
            .filter(\.status.isCompleted)
            .compactMap(\.target.volume)
            .reduce(0, +)

        self.kilograms = volume == 0 ? nil : volume
        self.unitSystem = .current
    }

    public static var info: String {
        String(localized: .statisticTotalVolumeInfo)
    }

    public static var tolerance: Double? {
        nil
    }

    public var pictogram: Pictogram {
        .volume
    }

    public var title: String {
        String(localized: .statisticTotalVolumeTitle)
    }

    public var value: Double? {
        kilograms
    }

    public var format: Format {
        VolumeFormat(system: unitSystem)
    }
}
