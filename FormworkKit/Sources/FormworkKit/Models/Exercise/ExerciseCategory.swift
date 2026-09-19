//
//  ExerciseCategory.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 04.09.26.
//

public enum ExerciseCategory: Identifiable, Codable, CaseIterable, Sendable {
    case arms, legs, chest, shoulders, core, back, cardio, flexibility, mindfulness, other

    public var id: Self {
        self
    }
}
