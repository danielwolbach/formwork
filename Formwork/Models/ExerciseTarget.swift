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

extension ExerciseTarget {
    static func defaults(for type: ExerciseType) -> Self {
        switch type {
        case .weight: .weight(weight: 10, sets: 3, reps: 10)
        case .bodyweight: .bodyweight(sets: 3, reps: 10)
        case .duration: .duration(minutes: 10)
        case .distance: .distance(meters: 1000)
        }
    }
}
