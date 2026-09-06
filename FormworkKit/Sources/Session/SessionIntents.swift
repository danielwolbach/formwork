//
//  SessionIntents.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 06.09.26.
//

import AppIntents

/// `LiveActivityIntent` is what makes `perform()` run inside the app rather
/// than the widget extension, which is the only reason these can reach
/// SwiftData at all.
public struct SessionCompleteIntent: LiveActivityIntent {
    public static let title: LocalizedStringResource = "Complete Exercise"

    public static let isDiscoverable = false

    public init() {}

    public func perform() async throws -> some IntentResult {
        await SessionControl.resolve()?.complete()
        return .result()
    }
}

public struct SessionUndoIntent: LiveActivityIntent {
    public static let title: LocalizedStringResource = "Undo Exercise"

    public static let isDiscoverable = false

    public init() {}

    public func perform() async throws -> some IntentResult {
        await SessionControl.resolve()?.undo()
        return .result()
    }
}

public struct SessionForwardIntent: LiveActivityIntent {
    public static let title: LocalizedStringResource = "Next Exercise"

    public static let isDiscoverable = false

    public init() {}

    public func perform() async throws -> some IntentResult {
        await SessionControl.resolve()?.moveToNext()
        return .result()
    }
}

public struct SessionBackwardIntent: LiveActivityIntent {
    public static let title: LocalizedStringResource = "Previous Exercise"

    public static let isDiscoverable = false

    public init() {}

    public func perform() async throws -> some IntentResult {
        await SessionControl.resolve()?.moveToPrevious()
        return .result()
    }
}
