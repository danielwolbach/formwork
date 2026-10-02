//
//  SessionVolume.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 02.10.26.
//

import Foundation

public struct SessionVolume {
    public let value: Double?

    public init(value: Double?) {
        self.value = value
    }
}

extension SessionVolume: SessionMeasure {
    public static var info: String {
        String(localized: .placeholder)
    }

    public static var pictogram: Pictogram {
        .volume
    }

    public static var title: String {
        String(localized: .placeholder)
    }

    public static func value(of session: Session) -> Double? {
        let volumes = session.entries.filter(\.status.isCompleted).compactMap(\.target.volume)
        return volumes.isEmpty ? nil : volumes.reduce(0, +)
    }

    public func reading(of value: Double) -> Reading {
        .weight(kilograms: value)
    }
}
