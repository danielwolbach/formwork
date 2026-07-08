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
    
    var description: String {
        switch self {
        case .weight(weight: let weight, sets: let sets, reps: let reps): "\(weight) kg, \(sets) sets, \(reps) reps"
        case .bodyweight(sets: let sets, reps: let reps): "\(sets) sets, \(reps) reps"
        case .duration(minutes: let minutes): "\(minutes) min"
        case .distance(meters: let meters): "\(meters) m"
        }
    }
    
    var metric: ExerciseMetric {
        switch self {
        case .weight(weight: _, sets: _, reps: _): .weight
        case .bodyweight(sets: _, reps: _): .bodyweight
        case .duration(minutes: _): .duration
        case .distance(meters: _): .distance
        }
    }
    
    static func defaults(for metric: ExerciseMetric) -> Self {
        switch metric {
        case .weight: .weight(weight: 10, sets: 3, reps: 10)
        case .bodyweight: .bodyweight(sets: 10, reps: 10)
        case .duration: .duration(minutes: 10)
        case .distance: .distance(meters: 1000)
        }
    }
}
