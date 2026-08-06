//
//  Discipline+Presentation.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import SwiftUI

extension Discipline {
    var title: LocalizedStringResource {
        switch self {
        case .arms: .disciplineArms
        case .legs: .disciplineLegs
        case .chest: .disciplineChest
        case .shoulders: .disciplineShoulders
        case .core: .disciplineCore
        case .back: .disciplineBack
        case .cardio: .disciplineCardio
        case .flexibility: .disciplineFlexibility
        case .mindfulness: .disciplineMindfulness
        case .other: .disciplineOther
        }
    }

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

    var icon: String {
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
