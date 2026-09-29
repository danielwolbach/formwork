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

extension EnvironmentValues {
    @Entry
    public var presentSession = PresentSessionAction { _ in }
}
