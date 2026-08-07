//
//  SessionActivityIntent.swift
//  GymTrack
//

import AppIntents
import Foundation

nonisolated enum SessionActivityAction: Sendable {
    case advance
    case complete
    case undo
}

struct SessionAdvanceActivityIntent: LiveActivityIntent {
    static var title: LocalizedStringResource {
        "action.forward"
    }

    @Parameter(title: "Session") var sessionID: String

    init(sessionID: String) {
        self.sessionID = sessionID
    }

    init() {}

    func perform() async throws -> some IntentResult {
        #if WIDGET_EXTENSION
            return .result()
        #else
            try await SessionActivityIntentHandler.perform(.advance, sessionID: sessionID)
            return .result()
        #endif
    }
}

struct SessionCompleteActivityIntent: LiveActivityIntent {
    static var title: LocalizedStringResource {
        "action.complete"
    }

    @Parameter(title: "Session") var sessionID: String

    init(sessionID: String) {
        self.sessionID = sessionID
    }

    init() {}

    func perform() async throws -> some IntentResult {
        #if WIDGET_EXTENSION
            return .result()
        #else
            try await SessionActivityIntentHandler.perform(.complete, sessionID: sessionID)
            return .result()
        #endif
    }
}

struct SessionUndoActivityIntent: LiveActivityIntent {
    static var title: LocalizedStringResource {
        "action.undo"
    }

    @Parameter(title: "Session") var sessionID: String

    init(sessionID: String) {
        self.sessionID = sessionID
    }

    init() {}

    func perform() async throws -> some IntentResult {
        #if WIDGET_EXTENSION
            return .result()
        #else
            try await SessionActivityIntentHandler.perform(.undo, sessionID: sessionID)
            return .result()
        #endif
    }
}
