//
//  SessionIntents.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 06.09.26.
//

import AppIntents

public struct SessionCompleteIntent: LiveActivityIntent {
    public static let title: LocalizedStringResource = "action.complete.title"

    public static let isDiscoverable = false

    public init() {}

    public func perform() async throws -> some IntentResult {
        await updateActiveSession { $0.completeAndAdvance() }
        return .result()
    }
}

public struct SessionUndoIntent: LiveActivityIntent {
    public static let title: LocalizedStringResource = "action.undo.title"

    public static let isDiscoverable = false

    public init() {}

    public func perform() async throws -> some IntentResult {
        await updateActiveSession { $0.undoStatusChange() }
        return .result()
    }
}

public struct SessionForwardIntent: LiveActivityIntent {
    public static let title: LocalizedStringResource = "action.forward.title"

    public static let isDiscoverable = false

    public init() {}

    public func perform() async throws -> some IntentResult {
        await updateActiveSession { $0.moveToNext() }
        return .result()
    }
}

public struct SessionBackwardIntent: LiveActivityIntent {
    public static let title: LocalizedStringResource = "action.backward.title"

    public static let isDiscoverable = false

    public init() {}

    public func perform() async throws -> some IntentResult {
        await updateActiveSession { $0.moveToPrevious() }
        return .result()
    }
}

@MainActor
private func updateActiveSession(_ change: (Session) -> Void) async {
    let context = Storage.container.mainContext

    guard let session = try? Session.active(in: context) else {
        return
    }

    change(session)
    try? context.save()

    await SessionActivity.sync(.init(session: session))
}
