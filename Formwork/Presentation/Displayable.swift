//
//  Displayable.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import FormworkKit
import Foundation

protocol Displayable {
    var title: String {
        get
    }

    var subtitle: String? {
        get
    }

    var pictogram: Pictogram {
        get
    }

    var badge: Pictogram? {
        get
    }
}

extension Displayable {
    var subtitle: String? {
        nil
    }

    var badge: Pictogram? {
        nil
    }
}

extension Exercise: Displayable {
    var title: String {
        name
    }

    var subtitle: String? {
        ExerciseCategory.allCases
            .filter { categories.contains($0) }
            .map(\.title)
            .joined(separator: ", ")
    }

    var pictogram: Pictogram {
        type.pictogram
    }
}

extension ExerciseCategory: Displayable {
    var title: String {
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

    var pictogram: Pictogram {
        switch self {
        case .arms: Pictogram(icon: "figure.dance", tint: .blue)
        case .legs: Pictogram(icon: "figure.walk", tint: .purple)
        case .chest: Pictogram(icon: "figure.arms.open", tint: .orange)
        case .shoulders: Pictogram(icon: "figure.play", tint: .indigo)
        case .core: Pictogram(icon: "figure.core.training", tint: .yellow)
        case .back: Pictogram(icon: "figure.indoor.rowing", tint: .green)
        case .cardio: Pictogram(icon: "figure.run", tint: .pink)
        case .flexibility: Pictogram(icon: "figure.yoga", tint: .mint)
        case .mindfulness: Pictogram(icon: "figure.mind.and.body", tint: .cyan)
        case .other: Pictogram(icon: "ellipsis.circle", tint: .gray)
        }
    }
}

extension ExerciseTarget: Displayable {
    var title: String {
        switch self {
        case let .weight(weight, sets, reps):
            String(localized: .exerciseTargetWeightTitle(
                weight: weight.formatted(.number.precision(.fractionLength(1))),
                sets: sets,
                reps: reps
            ))
        case let .bodyweight(sets, reps):
            String(localized: .exerciseTargetBodyweightTitle(sets: sets, reps: reps))
        case let .duration(minutes):
            String(localized: .exerciseTargetDurationTitle(minutes: minutes))
        case let .distance(meters):
            String(localized: .exerciseTargetDistanceTitle(meters: meters))
        }
    }

    var measure: String {
        switch self {
        case let .weight(weight, _, _):
            String(localized: .exerciseTargetWeightMeasure(weight: weight
                    .formatted(.number.precision(.fractionLength(1)))))
        case let .bodyweight(_, reps):
            String(localized: .exerciseTargetBodyweightMeasure(reps: reps))
        case let .duration(minutes):
            String(localized: .exerciseTargetDurationTitle(minutes: minutes))
        case let .distance(meters):
            String(localized: .exerciseTargetDistanceTitle(meters: meters))
        }
    }

    var pictogram: Pictogram {
        type.pictogram
    }
}

extension ExerciseType: Displayable {
    var title: String {
        switch self {
        case .weight: String(localized: .exerciseTypeWeightTitle)
        case .bodyweight: String(localized: .exerciseTypeBodyweightTitle)
        case .duration: String(localized: .exerciseTypeDurationTitle)
        case .distance: String(localized: .exerciseTypeDistanceTitle)
        }
    }

    var pictogram: Pictogram {
        switch self {
        case .weight: Pictogram(icon: "dumbbell", tint: .indigo)
        case .bodyweight: Pictogram(icon: "figure", tint: .pink)
        case .duration: Pictogram(icon: "timer", tint: .orange)
        case .distance: Pictogram(icon: "map", tint: .cyan)
        }
    }
}

extension Workout: Displayable {
    var title: String {
        name
    }

    var subtitle: String? {
        String(localized: .workoutSubtitle(exerciseCount: entries.count))
    }
}

extension WorkoutEntry: Displayable {
    var title: String {
        exercise?.title ?? String(localized: .exerciseUnknownTitle)
    }

    var subtitle: String? {
        target.title
    }

    var pictogram: Pictogram {
        exercise?.pictogram ?? .unknown
    }
}

extension Session: Displayable {
    var title: String {
        workout?.title ?? String(localized: .workoutUnknownTitle)
    }

    var subtitle: String? {
        started.formatted()
    }

    var pictogram: Pictogram {
        workout?.pictogram ?? .unknown
    }
}

extension SessionEntry: Displayable {
    var title: String {
        exercise?.title ?? String(localized: .exerciseUnknownTitle)
    }

    var subtitle: String? {
        target.title
    }

    var pictogram: Pictogram {
        exercise?.pictogram ?? .unknown
    }

    var badge: Pictogram? {
        status.isPending ? nil : status.pictogram
    }
}

extension SessionEntry.Status: Displayable {
    var title: String {
        switch self {
        case .pending: String(localized: .sessionStatusPendingTitle)
        case .completed: String(localized: .sessionStatusCompletedTitle)
        case .skipped: String(localized: .sessionStatusSkippedTitle)
        }
    }

    var pictogram: Pictogram {
        switch self {
        case .pending: Pictogram(icon: "circle.dotted", tint: .gray)
        case .completed: Pictogram(icon: "checkmark.circle.fill", tint: .green)
        case .skipped: Pictogram(icon: "forward.end.circle.fill", tint: .orange)
        }
    }
}

extension Pictogram.Tint {
    var title: String {
        switch self {
        case .blue: String(localized: .pictogramTintBlueTitle)
        case .indigo: String(localized: .pictogramTintIndigoTitle)
        case .purple: String(localized: .pictogramTintPurpleTitle)
        case .pink: String(localized: .pictogramTintPinkTitle)
        case .red: String(localized: .pictogramTintRedTitle)
        case .orange: String(localized: .pictogramTintOrangeTitle)
        case .yellow: String(localized: .pictogramTintYellowTitle)
        case .green: String(localized: .pictogramTintGreenTitle)
        case .mint: String(localized: .pictogramTintMintTitle)
        case .cyan: String(localized: .pictogramTintCyanTitle)
        case .brown: String(localized: .pictogramTintBrownTitle)
        case .gray: String(localized: .pictogramTintGrayTitle)
        }
    }
}
