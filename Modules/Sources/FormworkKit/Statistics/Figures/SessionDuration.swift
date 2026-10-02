//
//  SessionDuration.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 02.10.26.
//

import Foundation

public struct SessionDuration {
    public let value: Double?

    public init(value: Double?) {
        self.value = value
    }
}

extension SessionDuration: SessionMeasure {
    public static var info: String {
        String(localized: .placeholder)
    }

    public static var pictogram: Pictogram {
        .duration
    }

    public static var title: String {
        String(localized: .placeholder)
    }

    public static func value(of session: Session) -> Double? {
        session.duration
    }

    public func reading(of value: Double) -> Reading {
        .duration(seconds: value)
    }
}
