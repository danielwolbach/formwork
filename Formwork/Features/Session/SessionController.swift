//
//  SessionController.swift
//  Formwork
//
//  Created by Daniel Wolbach on 06.09.26.
//

import FormworkKit
import SwiftData

@MainActor
final class SessionController: SessionControlling {
    func complete() async {
        mutate { $0.completeAndAdvance() }
    }

    func undo() async {
        mutate { $0.undoStatusChange() }
    }

    func moveToNext() async {
        mutate { $0.moveToNext() }
    }

    func moveToPrevious() async {
        mutate { $0.moveToPrevious() }
    }

    private func mutate(_ change: (Session) -> Void) {
        let context = Storage.container.mainContext

        guard let session = try? Session.active(in: context) else {
            return
        }

        change(session)
        try? context.save()

        SessionActivityController.sync(session)
    }
}
