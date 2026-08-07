//
//  SessionActivityAttributes.swift
//  GymTrack
//

import ActivityKit
import Foundation

nonisolated struct SessionActivityAttributes: ActivityAttributes {
    nonisolated enum EntryStatus: Codable, Hashable {
        case pending
        case done
        case skipped
    }

    nonisolated struct ContentState: Codable, Hashable {
        var exerciseName: String
        var subtitle: String
        var completedCount: Int
        var totalCount: Int
        var entryStatus: EntryStatus
    }

    var sessionID: UUID
    var workoutName: String
    var started: Date
}
