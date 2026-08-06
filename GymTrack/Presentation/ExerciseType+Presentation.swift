//
//  ExerciseType+Presentation.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import Foundation
import SwiftUI

extension ExerciseType {
    var title: LocalizedStringResource {
        switch self {
        case .weight: .exerciseTypeWeight
        case .bodyweight: .exerciseTypeBodyweight
        case .duration: .exerciseTypeDuration
        case .distance: .exerciseTypeDistance
        }
    }

    var color: Color {
        switch self {
        case .weight: .indigo
        case .bodyweight: .pink
        case .duration: .orange
        case .distance: .cyan
        }
    }

    var icon: String {
        switch self {
        case .weight: "dumbbell"
        case .bodyweight: "figure"
        case .duration: "timer"
        case .distance: "map"
        }
    }
}
