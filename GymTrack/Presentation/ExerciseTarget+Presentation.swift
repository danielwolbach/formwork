//
//  ExerciseTarget+Presentation.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import SwiftUI

extension ExerciseTarget {
    var title: String {
        switch self {
        case let .weight(weight: weight, sets: sets, reps: reps):
            String(localized: .targetWeightSummary(weight: weight, sets: sets, reps: reps))
        case let .bodyweight(sets: sets, reps: reps):
            String(localized: .targetBodyweightSummary(sets: sets, reps: reps))
        case let .duration(minutes: minutes):
            String(localized: .targetDurationSummary(minutes: minutes))
        case let .distance(meters: meters):
            String(localized: .targetDistanceSummary(meters: meters))
        }
    }

    var color: Color {
        type.color
    }

    var icon: String {
        type.icon
    }
}
