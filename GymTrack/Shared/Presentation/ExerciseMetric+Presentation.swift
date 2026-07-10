//
//  ExerciseMetric+Presentation.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import SwiftUI

extension ExerciseMetric {
    var title: LocalizedStringKey {
        switch self {
        case .weight: "Weight"
        case .bodyweight: "Bodyweight"
        case .duration: "Duration"
        case .distance: "Distance"
        }
    }
}

extension ExerciseMetric {
    var systemImage: String {
        switch self {
        case .weight: "scalemass"
        case .bodyweight: "figure"
        case .duration: "timer"
        case .distance: "base.unit"
        }
    }
}

extension ExerciseMetric {
    var color: Color {
        switch self {
        case .weight: .indigo
        case .bodyweight: .pink
        case .duration: .orange
        case .distance: .cyan
        }
    }
}
