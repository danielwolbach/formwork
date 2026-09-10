//
//  SessionActivity.swift
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
        public var status: Pictogram?
        public var resolved: Int
        public var total: Int
        public var isPending: Bool
        public var isComplete: Bool
        public var canMoveForward: Bool
        public var canMoveBackward: Bool

        public init(
            title: String,
            subtitle: String?,
            pictogram: Pictogram,
            status: Pictogram?,
            resolved: Int,
            total: Int,
            isPending: Bool,
            isComplete: Bool,
            canMoveForward: Bool,
            canMoveBackward: Bool
        ) {
            self.title = title
            self.subtitle = subtitle
            self.pictogram = pictogram
            self.status = status
            self.resolved = resolved
            self.total = total
            self.isPending = isPending
            self.isComplete = isComplete
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

public protocol SessionControlling: Sendable {
    func complete() async

    func undo() async

    func moveToNext() async

    func moveToPrevious() async
}

@MainActor
public enum SessionControl {
    private static var controller: (any SessionControlling)?

    public static func register(_ controller: any SessionControlling) {
        Self.controller = controller
    }

    static func resolve() -> (any SessionControlling)? {
        controller
    }
}
