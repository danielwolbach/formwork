//
//  WorkoutEntry+Presentation.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 06.08.26.
//

import Foundation
import SwiftUI

@MainActor
extension WorkoutEntry {
    var title: String {
        exercise.title
    }

    var subtitle: String {
        target.title
    }

    var color: Color {
        target.color
    }

    var icon: String {
        target.icon
    }
}
