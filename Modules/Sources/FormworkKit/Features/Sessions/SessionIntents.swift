//
//  SessionIntents.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 06.09.26.
//

import AppIntents
import OSLog
import WidgetKit

/// Titles resolve from the app's and the widgets' catalogs: the system reads intent strings from the main bundle, never this package's.
public struct SessionCompleteIntent: LiveActivityIntent {
    public static let title: LocalizedStringResource = "intent.complete.title"

    public static let isDiscoverable = false

    public init() {}

    public func perform() async throws -> some IntentResult {
        await updateActiveSession { $0.completeAndAdvance() }
        return .result()
    }
}

public struct SessionUndoIntent: LiveActivityIntent {
    public static let title: LocalizedStringResource = "intent.undo.title"

    public static let isDiscoverable = false

    public init() {}

    public func perform() async throws -> some IntentResult {
        await updateActiveSession { $0.undoCurrentStatus() }
        return .result()
    }
}

public struct SessionForwardIntent: LiveActivityIntent {
    public static let title: LocalizedStringResource = "intent.forward.title"

    public static let isDiscoverable = false

    public init() {}

    public func perform() async throws -> some IntentResult {
        await updateActiveSession { $0.moveToNext() }
        return .result()
    }
}

public struct SessionBackwardIntent: LiveActivityIntent {
    public static let title: LocalizedStringResource = "intent.backward.title"

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

    let session: Session?

    do {
        session = try Session.active(in: context)
    } catch {
        Logger.session.error("Fetching active session for intent failed: \(error, privacy: .public)")
        return
    }

    guard let session else {
        Logger.session.notice("Ignored intent without an active session")
        return
    }

    change(session)

    do {
        try context.save()
    } catch {
        Logger.session.error("Saving session after intent failed: \(error, privacy: .public)")
    }

    if !session.isActive {
        WidgetCenter.shared.reloadAllTimelines()
    }

    await SessionActivity.sync(.init(session: session))
    await Health.shared.sync(session)
}
