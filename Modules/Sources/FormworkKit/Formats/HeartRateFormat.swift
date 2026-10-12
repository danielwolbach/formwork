//
//  HeartRateFormat.swift
//  FormworkModules
//
//  Created by Daniel Wolbach on 06.10.26.
//

import Foundation

struct HeartRateFormat: FormatStyle {
    func format(_ beatsPerMinute: Double) -> String {
        .init(localized: .formatHeartRateScheme(bpm: Int(beatsPerMinute.rounded())))
    }
}
