//
//  Exercise.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 04.09.26.
//

import Foundation
import SwiftData

@Model
public class Exercise {
    public enum Kind: String, Codable, CaseIterable, Sendable {
        case weight, bodyweight, duration, distance
    }

    public enum Category: String, Codable, CaseIterable, Sendable {
        case arms, legs, chest, shoulders, core, back, cardio, flexibility, mindfulness, other
    }

    public var id: UUID = UUID()

    public var name: String = ""

    public var kind: Kind = Kind.bodyweight

    public var categories: Set<Category> = []

    public var link: URL?

    public var notes: String = ""

    @Relationship(deleteRule: .cascade, inverse: \WorkoutEntry.exercise)
    public var workoutEntries: [WorkoutEntry]? = []

    @Relationship(deleteRule: .nullify, inverse: \SessionEntry.exercise)
    public var sessionEntries: [SessionEntry]? = []

    public var isArchived: Bool = false

    public var creationDate: Date = Date.distantPast

    public init(name: String, kind: Kind, categories: Set<Category>, link: URL? = nil, notes: String = "") {
        self.name = name
        self.kind = kind
        self.categories = categories
        self.link = link
        self.notes = notes
        self.creationDate = .now
    }
}

extension Exercise {
    public var pictogram: Pictogram {
        kind.pictogram
    }

    public var title: String {
        name
    }

    public var currentHighestTarget: ExerciseTarget? {
        (workoutEntries ?? [])
            .filter { $0.target.exerciseKind == kind }
            .max { $0.target.rank < $1.target.rank }?
            .target
    }
}

extension Exercise: Hashable {
    // Redundant with @Model's PersistentModel conformance, but declared explicitly so
    // synthesized Hashable conformances (e.g. History.Subject) see it without the macro expansion.
}

extension Exercise.Kind: Identifiable {
    public var id: Self {
        self
    }
}

extension Exercise.Kind {
    public var pictogram: Pictogram {
        switch self {
        case .weight: .init(image: "dumbbell", tint: .indigo)
        case .bodyweight: .init(image: "scalemass", tint: .pink)
        case .duration: .init(image: "timer", tint: .orange)
        case .distance: .init(image: "map", tint: .cyan)
        }
    }

    public var title: String {
        switch self {
        case .weight: .init(localized: .exerciseKindWeightTitle)
        case .bodyweight: .init(localized: .exerciseKindBodyweightTitle)
        case .duration: .init(localized: .exerciseKindDurationTitle)
        case .distance: .init(localized: .exerciseKindDistanceTitle)
        }
    }
}

extension Exercise.Category: Identifiable {
    public var id: Self {
        self
    }
}

extension Exercise.Category {
    public var pictogram: Pictogram {
        switch self {
        case .arms: .init(image: "figure.dance", tint: .blue)
        case .legs: .init(image: "figure.walk", tint: .purple)
        case .chest: .init(image: "figure.arms.open", tint: .orange)
        case .shoulders: .init(image: "figure.play", tint: .indigo)
        case .core: .init(image: "figure.core.training", tint: .yellow)
        case .back: .init(image: "figure.indoor.rowing", tint: .green)
        case .cardio: .init(image: "figure.run", tint: .pink)
        case .flexibility: .init(image: "figure.yoga", tint: .mint)
        case .mindfulness: .init(image: "figure.mind.and.body", tint: .cyan)
        case .other: .init(image: "ellipsis.circle", tint: .gray)
        }
    }

    public var title: String {
        switch self {
        case .arms: .init(localized: .exerciseCategoryArmsTitle)
        case .legs: .init(localized: .exerciseCategoryLegsTitle)
        case .chest: .init(localized: .exerciseCategoryChestTitle)
        case .shoulders: .init(localized: .exerciseCategoryShouldersTitle)
        case .core: .init(localized: .exerciseCategoryCoreTitle)
        case .back: .init(localized: .exerciseCategoryBackTitle)
        case .cardio: .init(localized: .exerciseCategoryCardioTitle)
        case .flexibility: .init(localized: .exerciseCategoryFlexibilityTitle)
        case .mindfulness: .init(localized: .exerciseCategoryMindfulnessTitle)
        case .other: .init(localized: .exerciseCategoryOtherTitle)
        }
    }
}
