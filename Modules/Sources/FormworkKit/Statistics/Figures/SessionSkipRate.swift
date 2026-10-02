//
//  SessionSkipRate.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 02.10.26.
//

import Foundation

public struct SessionSkipRate {
    public let value: Double?

    public init(value: Double?) {
        self.value = value
    }
}

extension SessionSkipRate: SessionMeasure {
    public static var info: String {
        String(localized: .placeholder)
    }

    public static var pictogram: Pictogram {
        .skipped
    }

    public static var title: String {
        String(localized: .placeholder)
    }

    public static func value(of session: Session) -> Double? {
        session.entries.isEmpty ? nil : Double(session.entries.count(where: \.status.isSkipped)) / Double(session.entries.count)
    }

    public func reading(of value: Double) -> Reading {
        .percent(value)
    }
}
