//
//  Displayable.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import Foundation

public protocol Displayable {
    var pictogram: Pictogram {
        get
    }

    var title: String {
        get
    }

    var subtitle: String? {
        get
    }
}

public extension Displayable {
    var subtitle: String? {
        nil
    }
}

extension Exercise: Displayable {
    public var pictogram: Pictogram {
        type.pictogram
    }

    public var title: String {
        name
    }

    public var subtitle: String? {
        let titles = ExerciseCategory.allCases.filter { categories.contains($0) }.map(\.title)
        return titles.isEmpty ? nil : titles.joined(separator: ", ")
    }
}

public extension Exercise {
    static func countTitle(_ count: Int) -> LocalizedStringResource {
        .exerciseCountTitle(count)
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

extension ExerciseTarget: Displayable {
    public var type: ExerciseType {
        switch self {
        case .weight: .weight
        case .bodyweight: .bodyweight
        case .duration: .duration
        case .distance: .distance
        }
    }

    public var pictogram: Pictogram {
        type.pictogram
    }

    public var title: String {
        type.title
    }

    public var subtitle: String? {
        switch self {
        case let .weight(target): String(localized: .exerciseTargetWeightSubtitle(target.weight.formatted, target.sets, target.reps))
        case let .bodyweight(target): String(localized: .exerciseTargetBodyweightSubtitle(target.sets, target.reps))
        case let .duration(target): target.duration.formatted
        case let .distance(target): target.distance.formatted
        }
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

extension Workout: Displayable {
    public var title: String {
        name
    }

    public var subtitle: String? {
        String(localized: Exercise.countTitle(entries.count))
    }
}

extension WorkoutEntry: Displayable {
    public var pictogram: Pictogram {
        exercise?.pictogram ?? .unknown
    }

    public var title: String {
        exercise?.title ?? String(localized: .exerciseUnknownTitle)
    }

    public var subtitle: String? {
        target.subtitle
    }
}

extension Session: Displayable {
    public var title: String {
        workout?.title ?? String(localized: .workoutUnknownTitle)
    }

    public var subtitle: String? {
        started.formatted()
    }

    public var pictogram: Pictogram {
        workout?.pictogram ?? .unknown
    }
}

extension SessionEntry: Displayable {
    public var pictogram: Pictogram {
        exercise?.pictogram ?? .unknown
    }

    public var title: String {
        exercise?.title ?? String(localized: .exerciseUnknownTitle)
    }

    public var subtitle: String? {
        target.subtitle
    }
}

extension SessionEntry.Status: Displayable {
    public var pictogram: Pictogram {
        switch self {
        case .pending: Pictogram(image: "ellipsis.circle.fill", tint: .gray)
        case .completed: Pictogram(image: "checkmark.circle.fill", tint: .green)
        case .skipped: Pictogram(image: "arrowtriangle.forward.circle.fill", tint: .orange)
        }
    }

    public var title: String {
        switch self {
        case .pending: String(localized: .sessionEntryStatusPendingTitle)
        case .completed: String(localized: .sessionEntryStatusCompletedTitle)
        case .skipped: String(localized: .sessionEntryStatusSkippedTitle)
        }
    }
}

extension Statistic: Displayable {}
