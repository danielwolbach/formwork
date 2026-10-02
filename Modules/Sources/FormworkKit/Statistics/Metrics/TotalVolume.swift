//
//  TotalVolume.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 28.09.26.
//

import Foundation

public struct TotalVolume {
    public let kilograms: Double?
}

extension TotalVolume: Metric {
    public init(_ window: History.Window) {
        let volume = window.entries
            .filter(\.status.isCompleted)
            .compactMap(\.target.volume)
            .reduce(0, +)

        self.kilograms = volume == 0 ? nil : volume
    }

    public static var info: String {
        String(localized: .statisticTotalVolumeInfo)
    }

    public static var pictogram: Pictogram {
        .volume
    }

    public static var title: String {
        String(localized: .statisticTotalVolumeTitle)
    }

    public static var tolerance: Double? {
        nil
    }

    public var value: Double? {
        kilograms
    }

    public func reading(of value: Double) -> Reading {
        .weight(kilograms: value)
    }
}
