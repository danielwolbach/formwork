//
//  IntervalFormat.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 28.09.26.
//

import Foundation

struct IntervalFormat: FormatStyle {
    func format(_ days: Double) -> String {
        Duration.seconds(days * 86400).formatted(.units(allowed: [.days], width: .abbreviated))
    }
}
