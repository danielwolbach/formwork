//
//  ExerciseTarget+Presentation.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import SwiftUI

extension ExerciseTarget {
    var summary: Text {
        switch self {
        case let .weight(weight: weight, sets: sets, reps: reps):
            Text("\(weight, format: .number) kg, \(sets) sets, \(reps) reps")
        case let .bodyweight(sets: sets, reps: reps):
            Text("\(sets) sets, \(reps) reps")
        case let .duration(minutes: minutes):
            Text("\(minutes) min")
        case let .distance(meters: meters):
            Text("\(meters) m")
        }
    }
}

extension ExerciseTarget {
    var systemImage: String {
        metric.systemImage
    }
}

extension ExerciseTarget {
    var color: Color {
        metric.color
    }
}
