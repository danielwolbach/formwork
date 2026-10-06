//
//  HeartRateFormat.swift
//  FormworkModules
//
//  Created by Daniel Wolbach on 06.10.26.
//

import Foundation

public struct HeartRateFormat: FormatStyle {
    public init() {
        // Nothing to initialize.
    }

    public func format(_ beatsPerMinute: Double) -> String {
        .init(localized: .formatHeartRateScheme(bpm: Int(beatsPerMinute.rounded())))
    }
}

extension FormatStyle where Self == HeartRateFormat {
    public static var heartRate: HeartRateFormat {
        HeartRateFormat()
    }
}
