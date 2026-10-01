//
//  Environment.swift
//  FormworkUI
//
//  Created by Daniel Wolbach on 05.09.26.
//

import FormworkKit
import SwiftUI

public struct PresentSessionAction {
    private let action: (Session) -> Void

    public init(action: @escaping (Session) -> Void) {
        self.action = action
    }

    public func callAsFunction(_ session: Session) {
        action(session)
    }
}

public struct PresentPaywallAction {
    private let action: () -> Void

    public init(action: @escaping () -> Void) {
        self.action = action
    }

    public func callAsFunction() {
        action()
    }
}

extension FullVersion {
    /// Shared, so reading the entry without an injected one doesn't allocate a new one each time.
    fileprivate nonisolated static let fallback = FullVersion()
}

extension EnvironmentValues {
    @Entry
    public var presentSession = PresentSessionAction { _ in }

    @Entry
    public var presentPaywall = PresentPaywallAction {}

    @Entry
    public var fullVersion: FullVersion = .fallback

    @Entry
    public var units: Units = .current
}
