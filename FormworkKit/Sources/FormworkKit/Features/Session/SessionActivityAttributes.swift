//
//  SessionActivityAttributes.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 06.09.26.
//

import ActivityKit
import Foundation

/// Everything lives in the content state, so a replaced session updates the running activity instead of needing a
/// new one.
public struct SessionActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable, Sendable {
        public var title: String
        public var subtitle: String?
        public var pictogram: Pictogram
        public var workout: Pictogram
        public var status: Pictogram?
        public var started: Date
        public var resolved: Int
        public var total: Int
        public var canMoveForward: Bool
        public var canMoveBackward: Bool

        public init(
            title: String,
            subtitle: String?,
            pictogram: Pictogram,
            workout: Pictogram,
            status: Pictogram?,
            started: Date,
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
            self.started = started
            self.resolved = resolved
            self.total = total
            self.canMoveForward = canMoveForward
            self.canMoveBackward = canMoveBackward
        }
    }

    public init() {}
}

public extension SessionActivityAttributes.ContentState {
    init?(session: Session) {
        guard let current = session.currentEntry else {
            return nil
        }

        self.init(
            title: current.title,
            subtitle: current.target.subtitle,
            pictogram: current.pictogram,
            workout: session.workout?.pictogram ?? .workout,
            status: current.status.isPending ? nil : current.status.pictogram,
            started: session.started,
            resolved: session.resolvedCount,
            total: session.entries.count,
            canMoveForward: session.nextEntry != nil,
            canMoveBackward: session.previousEntry != nil
        )
    }
}
