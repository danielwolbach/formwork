//
//  SessionCompletedExercises.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 02.10.26.
//

import Foundation

public struct SessionCompletedExercises {
    public let value: Double?

    public init(value: Double?) {
        self.value = value
    }
}

extension SessionCompletedExercises: SessionMeasure {
    public static var info: String {
        String(localized: .placeholder)
    }

    public static var pictogram: Pictogram {
        .completed
    }

    public static var title: String {
        String(localized: .placeholder)
    }

    public static func value(of session: Session) -> Double? {
        Double(session.entries.count(where: \.status.isCompleted))
    }

    public func reading(of value: Double) -> Reading {
        .count(Int(value.rounded()))
    }
}
