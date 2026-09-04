//
//  ExerciseType.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import Foundation

nonisolated enum ExerciseType: Identifiable, Codable, CaseIterable {
    case weight
    case bodyweight
    case duration
    case distance
    
    var id: Self {
        self
    }
}
