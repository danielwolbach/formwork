//
//  ExerciseCategory.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 04.09.26.
//

public enum ExerciseCategory: String, Codable, CaseIterable, Sendable {
    case arms, legs, chest, shoulders, core, back, cardio, flexibility, mindfulness, other
}

extension ExerciseCategory: Identifiable {
    public var id: Self {
        self
    }
}

extension ExerciseCategory: Displayable {
    public var pictogram: Pictogram {
        switch self {
        case .arms: Pictogram(image: "figure.dance", tint: .blue)
        case .legs: Pictogram(image: "figure.walk", tint: .purple)
        case .chest: Pictogram(image: "figure.arms.open", tint: .orange)
        case .shoulders: Pictogram(image: "figure.play", tint: .indigo)
        case .core: Pictogram(image: "figure.core.training", tint: .yellow)
        case .back: Pictogram(image: "figure.indoor.rowing", tint: .green)
        case .cardio: Pictogram(image: "figure.run", tint: .pink)
        case .flexibility: Pictogram(image: "figure.yoga", tint: .mint)
        case .mindfulness: Pictogram(image: "figure.mind.and.body", tint: .cyan)
        case .other: Pictogram(image: "ellipsis.circle", tint: .gray)
        }
    }

    public var title: String {
        switch self {
        case .arms: String(localized: .exerciseCategoryArmsTitle)
        case .legs: String(localized: .exerciseCategoryLegsTitle)
        case .chest: String(localized: .exerciseCategoryChestTitle)
        case .shoulders: String(localized: .exerciseCategoryShouldersTitle)
        case .core: String(localized: .exerciseCategoryCoreTitle)
        case .back: String(localized: .exerciseCategoryBackTitle)
        case .cardio: String(localized: .exerciseCategoryCardioTitle)
        case .flexibility: String(localized: .exerciseCategoryFlexibilityTitle)
        case .mindfulness: String(localized: .exerciseCategoryMindfulnessTitle)
        case .other: String(localized: .exerciseCategoryOtherTitle)
        }
    }
}
