//
//  DurationFormat.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import Foundation

public struct DurationFormat: FormatStyle {
    public init() {}

    public func format(_ seconds: Double) -> String {
        if seconds < 60 {
            return Duration.seconds(seconds).formatted(.units(allowed: [.seconds], width: .abbreviated))
        }

        let minutes = Duration.seconds((seconds / 60).rounded() * 60)
        return minutes.formatted(.units(allowed: [.hours, .minutes], width: .abbreviated))
    }
}
