//
//  SessionExerciseDuration.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 02.10.26.
//

import Foundation

public struct SessionExerciseDuration {
    public let value: Double?

    public init(value: Double?) {
        self.value = value
    }
}

extension SessionExerciseDuration: SessionMeasure {
    public static var info: String {
        String(localized: .placeholder)
    }

    public static var pictogram: Pictogram {
        .pace
    }

    public static var title: String {
        String(localized: .placeholder)
    }

    public static func value(of session: Session) -> Double? {
        session.entries.compactMap(\.duration).median
    }

    public func reading(of value: Double) -> Reading {
        .duration(seconds: value)
    }
}
