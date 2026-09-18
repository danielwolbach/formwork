//
//  ExerciseType.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 04.09.26.
//

public enum ExerciseType: Identifiable, Codable, CaseIterable, Sendable {
    case weight, bodyweight, duration, distance

    public var id: Self {
        self
    }
}
