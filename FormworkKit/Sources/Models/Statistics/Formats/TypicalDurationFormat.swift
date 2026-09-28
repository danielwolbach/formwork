//
//  TypicalDurationFormat.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import Foundation

public struct TypicalDurationFormat: FormatStyle {
    public func format(_ seconds: Double) -> String {
        let minutes = Duration.seconds((seconds / 60).rounded() * 60)

        if seconds < 60 {
            return Duration.seconds(seconds).formatted(.units(allowed: [.seconds], width: .abbreviated))
        }

        if minutes < .seconds(3600) {
            return minutes.formatted(.units(allowed: [.minutes], width: .abbreviated))
        }

        return minutes.formatted(.time(pattern: .hourMinute))
    }
}
