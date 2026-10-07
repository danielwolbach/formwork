//
//  SessionStarter.swift
//  Formwork
//
//  Created by Daniel Wolbach on 07.10.26.
//

import FormworkKit
import FormworkUI
import SwiftData
import SwiftUI

extension View {
    func sessionStarter() -> some View {
        modifier(SessionStarter())
    }
}

private struct SessionStarter: ViewModifier {
    @Environment(\.presentSession)
    private var presentSession: PresentSessionAction

    @Query(Session.activeDescriptor)
    private var activeSessions: [Session]

    @State
    private var replaceSessionAlert: Bool = false

    @State
    private var pendingWorkout: Workout? = nil

    func body(content: Content) -> some View {
        content
            .environment(\.startSession, StartSessionAction(action: start))
            .alert(.alertReplaceSessionTitle, isPresented: $replaceSessionAlert, presenting: pendingWorkout) { workout in
                Button(.replaceSession) {
                    replace(with: workout)
                }

                if let session = activeSessions.first {
                    Button(.resumeSession) {
                        presentSession(session)
                    }
                }

                Button(.cancel) {
                    // Works automatically.
                }
            } message: { _ in
                Text(.alertReplaceSessionMessage)
            }
    }

    private func start(_ workout: Workout) {
        guard activeSessions.isEmpty else {
            pendingWorkout = workout
            replaceSessionAlert = true
            return
        }

        replace(with: workout)
    }

    private func replace(with workout: Workout) {
        if let session = workout.startSession() {
            presentSession(session)
        }
    }
}
