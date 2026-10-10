//
//  SessionActivityAttributes.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 06.09.26.
//

import ActivityKit
import Foundation

public struct SessionActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable, Sendable {
        public var entryID: UUID

        public var title: String

        public var target: ExerciseTarget

        public var pictogram: Pictogram

        public var workout: Pictogram

        public var status: Pictogram?

        public var startDate: Date

        public var resolved: Int

        public var total: Int

        public var canMoveForward: Bool

        public var canMoveBackward: Bool

        public init(
            entryID: UUID,
            title: String,
            target: ExerciseTarget,
            pictogram: Pictogram,
            workout: Pictogram,
            status: Pictogram?,
            startDate: Date,
            resolved: Int,
            total: Int,
            canMoveForward: Bool,
            canMoveBackward: Bool
        ) {
            self.entryID = entryID
            self.title = title
            self.target = target
            self.pictogram = pictogram
            self.workout = workout
            self.status = status
            self.startDate = startDate
            self.resolved = resolved
            self.total = total
            self.canMoveForward = canMoveForward
            self.canMoveBackward = canMoveBackward
        }
    }

    public init() {}
}

extension SessionActivityAttributes.ContentState {
    public init?(session: Session) {
        guard let current = session.currentEntry else {
            return nil
        }

        self.init(
            entryID: current.id,
            title: current.title,
            target: current.target,
            pictogram: current.pictogram,
            workout: session.workout?.pictogram ?? .workout,
            status: current.status.isPending ? nil : current.status.pictogram,
            startDate: session.startDate,
            resolved: session.resolvedCount,
            total: (session.entries ?? []).count,
            canMoveForward: session.nextEntry != nil,
            canMoveBackward: session.previousEntry != nil
        )
    }
}
