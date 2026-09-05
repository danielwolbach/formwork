//
//  Displayable.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import Foundation
import SwiftUI

protocol Displayable {
    var title: String {
        get
    }
    
    var pictogram: Pictogram {
        get
    }
}

protocol SubtitledDisplayable: Displayable {
    var subtitle: String {
        get
    }
}

extension Exercise: SubtitledDisplayable {
    var title: String {
        name
    }
    
    var subtitle: String {
        ExerciseCategory.allCases
            .filter { categories.contains($0) }
            .map { $0.title }
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
        case .arms: Pictogram(icon: "figure.dance", color: .blue)
        case .legs: Pictogram(icon: "figure.walk", color: .purple)
        case .chest: Pictogram(icon: "figure.arms.open", color: .orange)
        case .shoulders: Pictogram(icon: "figure.play", color: .indigo)
        case .core: Pictogram(icon: "figure.core.training", color: .yellow)
        case .back: Pictogram(icon: "figure.indoor.rowing", color: .green)
        case .cardio: Pictogram(icon: "figure.run", color: .pink)
        case .flexibility: Pictogram(icon: "figure.yoga", color: .mint)
        case .mindfulness: Pictogram(icon: "figure.mind.and.body", color: .teal)
        case .other: Pictogram(icon: "ellipsis.circle", color: .gray)
        }
    }
}


extension ExerciseTarget: Displayable {
    var title: String {
        switch self {
        case let .weight(weight, sets, reps):
            String(localized: .exerciseTargetWeightTitle(weight: weight.formatted(.number.precision(.fractionLength(1))), sets: sets, reps: reps))
        case let .bodyweight(sets, reps):
            String(localized: .exerciseTargetBodyweightTitle(sets: sets, reps: reps))
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
        case .weight: Pictogram(icon: "dumbbell", color: .indigo)
        case .bodyweight: Pictogram(icon: "figure", color: .pink)
        case .duration: Pictogram(icon: "timer", color: .orange)
        case .distance: Pictogram(icon: "map", color: .teal)
        }
    }
}

extension Workout: SubtitledDisplayable {
    var title: String {
        name
    }
    
    var subtitle: String {
        String(localized: .workoutSubtitle(exerciseCount: entries.count))
    }
    
    var pictogram: Pictogram {
        .init(icon: "clipboard", color: .accentColor)
    }
}

extension WorkoutEntry: SubtitledDisplayable {
    var title: String {
        exercise?.title ?? String(localized: .unknown)
    }
    
    var subtitle: String {
        target.title
    }
    
    var pictogram: Pictogram {
        target.pictogram
    }
}

extension SessionEntry: SubtitledDisplayable {
    var title: String {
        exercise?.title ?? String(localized: .unknown)
    }
    
    var subtitle: String {
        target.title
    }
    
    var pictogram: Pictogram {
        target.pictogram
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
        case .pending: Pictogram(icon: "circle.dotted", color: .gray)
        case .completed: Pictogram(icon: "checkmark.circle.fill", color: .green)
        case .skipped: Pictogram(icon: "forward.end.circle.fill", color: .orange)
        }
    }
}
