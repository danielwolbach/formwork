//
//  SessionEntry.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import SwiftData

@Model
final class SessionEntry: Comparable {
    var order: Int
    
    var current: Int
    
    var status: Status
    
    var exercise: Exercise
    
    var target: ExerciseTarget
    
    init(order: Int, exercise: Exercise, target: ExerciseTarget) {
        self.order = order
        self.current = 0
        self.status = .pending
        self.exercise = exercise
        self.target = target
    }
    
    static func < (lhs: SessionEntry, rhs: SessionEntry) -> Bool {
        lhs.order < rhs.order
    }
}

extension SessionEntry {
    nonisolated enum Status: Codable {
        case pending
        case skipped
        case done
    }
}
