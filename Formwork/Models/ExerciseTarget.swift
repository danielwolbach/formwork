//
//  ExerciseTarget.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import Foundation

nonisolated enum ExerciseTarget: Codable {
    case weight(weight: Double, sets: Int, reps: Int)
    case bodyweight(sets: Int, reps: Int)
    case duration(minutes: Int)
    case distance(meters: Int)
}

extension ExerciseTarget {
    var type: ExerciseType {
        switch self {
        case .weight: .weight
        case .bodyweight: .bodyweight
        case .duration: .duration
        case .distance: .distance
        }
    }
}
