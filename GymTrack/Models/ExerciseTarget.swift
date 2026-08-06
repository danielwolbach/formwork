//
//  ExerciseTarget.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

nonisolated enum ExerciseTarget: Identifiable, Codable, Hashable {
    case weight(weight: Double, sets: Int, reps: Int)
    case bodyweight(sets: Int, reps: Int)
    case duration(minutes: Int)
    case distance(meters: Int)

    var id: Self {
        self
    }

    var type: ExerciseType {
        switch self {
        case .weight: .weight
        case .bodyweight: .bodyweight
        case .duration: .duration
        case .distance: .distance
        }
    }

    static func defaults(for type: ExerciseType) -> Self {
        switch type {
        case .weight: .weight(weight: 10, sets: 3, reps: 10)
        case .bodyweight: .bodyweight(sets: 3, reps: 10)
        case .duration: .duration(minutes: 10)
        case .distance: .distance(meters: 1000)
        }
    }
}
