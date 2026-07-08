//
//  ExerciseTarget+Presentation.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

extension ExerciseTarget {
    var description: String {
        switch self {
        case let .weight(weight: weight, sets: sets, reps: reps): "\(weight) kg, \(sets) sets, \(reps) reps"
        case let .bodyweight(sets: sets, reps: reps): "\(sets) sets, \(reps) reps"
        case let .duration(minutes: minutes): "\(minutes) min"
        case let .distance(meters: meters): "\(meters) m"
        }
    }
}
