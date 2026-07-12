//
//  PresentSessionAction.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 12.07.26.
//

import SwiftUI

struct PresentSessionAction {
    private let action: (Session) -> Void

    init(action: @escaping (Session) -> Void = { _ in }) {
        self.action = action
    }

    func callAsFunction(_ session: Session) {
        action(session)
    }
}

private struct PresentSessionActionKey: EnvironmentKey {
    static let defaultValue = PresentSessionAction()
}

extension EnvironmentValues {
    var presentSession: PresentSessionAction {
        get { self[PresentSessionActionKey.self] }
        set { self[PresentSessionActionKey.self] = newValue }
    }
}
