//
//  ExerciseType.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 04.09.26.
//

public enum ExerciseType: Codable, CaseIterable, Sendable {
    case weight, bodyweight, duration, distance
}

extension ExerciseType: Identifiable {
    public var id: Self {
        self
    }
}

extension ExerciseType: Displayable {
    public var pictogram: Pictogram {
        switch self {
        case .weight: Pictogram(image: "dumbbell", tint: .indigo)
        case .bodyweight: Pictogram(image: "figure", tint: .pink)
        case .duration: Pictogram(image: "timer", tint: .orange)
        case .distance: Pictogram(image: "map", tint: .cyan)
        }
    }

    public var title: String {
        switch self {
        case .weight: String(localized: .exerciseTypeWeightTitle)
        case .bodyweight: String(localized: .exerciseTypeBodyweightTitle)
        case .duration: String(localized: .exerciseTypeDurationTitle)
        case .distance: String(localized: .exerciseTypeDistanceTitle)
        }
    }
}
