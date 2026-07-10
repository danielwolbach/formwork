//
//  Workout+Presentation.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import SwiftUI

extension Workout {
    var entriesText: Text {
        Text("\(entries.count) Exercises")
    }
}

extension Workout {
    var systemImage: String {
        Workout.systemImage
    }
}

extension Workout {
    var color: Color {
        Workout.color
    }
}

extension Workout {
    static let systemImage = "clipboard"
}

extension Workout {
    static let color = Color.accentColor
}
