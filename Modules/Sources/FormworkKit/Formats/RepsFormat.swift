//
//  RepsFormat.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 12.10.26.
//

import Foundation

struct RepsFormat: FormatStyle {
    func format(_ reps: Int) -> String {
        String(localized: .exerciseTargetBodyweightRank(count: reps))
    }
}
