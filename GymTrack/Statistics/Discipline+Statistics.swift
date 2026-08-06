//
//  Discipline+Statistics.swift
//  GymTrack
//  Created by Daniel Wolbach on 06.08.26.
//

import Foundation

extension [Discipline: Double] {
    init(exercises: [Exercise]) {
        self = exercises.reduce(into: [:]) { result, exercise in
            guard !exercise.disciplines.isEmpty else { return }
            let share = 1 / Double(exercise.disciplines.count)
            for discipline in exercise.disciplines {
                result[discipline, default: 0] += share
            }
        }
    }
}
