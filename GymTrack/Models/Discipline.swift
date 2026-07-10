//
//  Discipline.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import Foundation

nonisolated enum Discipline: String, Identifiable, Codable, Hashable, CaseIterable {
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
