//
//  PresentSessionAction.swift
//  Formwork
//
//  Created by Daniel Wolbach on 05.09.26.
//

import SwiftUI

struct PresentSessionAction {
    private let action: (Session) -> Void
    
    init(action: @escaping (Session) -> Void) {
        self.action = action
    }
    
    func callAsFunction(_ session: Session) {
        action(session)
    }
}

extension EnvironmentValues {
    @Entry var presentSession = PresentSessionAction { _ in }
}
