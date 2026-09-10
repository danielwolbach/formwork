//
//  ExerciseCategory.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import Foundation

nonisolated enum ExerciseCategory: Identifiable, Codable, CaseIterable {
    case arms
    case legs
    case chest
    case shoulders
    case core
    case back
    case cardio
    case flexibility
    case mindfulness
    case other

    var id: Self {
        self
    }
}
