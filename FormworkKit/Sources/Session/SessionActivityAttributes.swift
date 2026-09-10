//
//  SessionActivityAttributes.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 06.09.26.
//

import ActivityKit
import Foundation

public nonisolated struct SessionActivityAttributes: ActivityAttributes {
    public nonisolated struct ContentState: Codable, Hashable, Sendable {
        public var title: String
        public var subtitle: String?
        public var pictogram: Pictogram
        public var workout: Pictogram
        public var status: Pictogram?
        public var resolved: Int
        public var total: Int
        public var canMoveForward: Bool
        public var canMoveBackward: Bool

        /// An entry carries a status pictogram exactly once it has been resolved,
        /// so its absence *is* the pending state — it is not tracked separately.
        public var isPending: Bool {
            status == nil
        }

        public init(
            title: String,
            subtitle: String?,
            pictogram: Pictogram,
            workout: Pictogram,
            status: Pictogram?,
            resolved: Int,
            total: Int,
            canMoveForward: Bool,
            canMoveBackward: Bool
        ) {
            self.title = title
            self.subtitle = subtitle
            self.pictogram = pictogram
            self.workout = workout
            self.status = status
            self.resolved = resolved
            self.total = total
            self.canMoveForward = canMoveForward
            self.canMoveBackward = canMoveBackward
        }
    }

    public var workout: String

    public var started: Date

    public init(workout: String, started: Date) {
        self.workout = workout
        self.started = started
    }
}
