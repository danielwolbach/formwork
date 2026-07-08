//
//  ExerciseTarget+Presentation.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

extension ExerciseTarget {
    var description: String {
        switch self {
        case .weight(weight: let weight, sets: let sets, reps: let reps): "\(weight) kg, \(sets) sets, \(reps) reps"
        case .bodyweight(sets: let sets, reps: let reps): "\(sets) sets, \(reps) reps"
        case .duration(minutes: let minutes): "\(minutes) min"
        case .distance(meters: let meters): "\(meters) m"
        }
    }
}
