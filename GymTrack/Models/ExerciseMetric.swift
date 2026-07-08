//
//  ExerciseMetric.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import Foundation

nonisolated enum ExerciseMetric: String, Identifiable, Codable, Hashable, CaseIterable {
    case weight
    case bodyweight
    case duration
    case distance
    
    var id: Self {
        self
    }
    
    var description: String {
        self.rawValue.capitalized
    }
}
