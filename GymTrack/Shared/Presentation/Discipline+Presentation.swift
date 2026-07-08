//
//  Discipline+Presentation.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import SwiftUI

extension Discipline {
    var systemImage: String {
        switch self {
        case .arms: "figure.dance"
        case .legs: "figure.walk"
        case .chest: "figure.arms.open"
        case .shoulders: "figure.play"
        case .core: "figure.core.training"
        case .back: "figure.indoor.rowing"
        case .cardio: "figure.run"
        case .flexibility: "figure.yoga"
        case .mindfulness: "figure.mind.and.body"
        case .other: "ellipsis.circle"
        }
    }
}

extension Discipline {
    var color: Color {
        switch self {
        case .arms: .blue
        case .legs: .purple
        case .chest: .orange
        case .shoulders: .indigo
        case .core: .yellow
        case .back: .green
        case .cardio: .pink
        case .flexibility: .mint
        case .mindfulness: .teal
        case .other: .gray
        }
    }
}
