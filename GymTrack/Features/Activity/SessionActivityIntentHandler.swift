//
//  SessionActivityIntentHandler.swift
//  GymTrack
//

import Foundation
import SwiftData

@MainActor
enum SessionActivityIntentHandler {
    static func perform(_ action: SessionActivityAction, sessionID: String) async throws {
        guard let sessionID = UUID(uuidString: sessionID) else {
            return
        }

        let context = ModelContainerInstance.shared.mainContext
        let descriptor = FetchDescriptor<Session>(predicate: #Predicate { $0.activity == sessionID })

        guard let session = try context.fetch(descriptor).first else {
            return
        }

        guard session.isActive else {
            return
        }

        switch action {
        case .advance:
            if let next = session.next {
                session.current = next
            } else if let firstEntry = session.firstEntry {
                session.current = firstEntry
            }

        case .complete:
            session.completeAndAdvance()

        case .undo:
            session.undoStatusChange()
        }

        try context.save()
        await SessionActivityCoordinator.update(for: session)
    }
}
