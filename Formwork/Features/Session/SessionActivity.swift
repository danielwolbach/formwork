//
//  SessionActivity.swift
//  Formwork
//
//  Created by Daniel Wolbach on 06.09.26.
//

import ActivityKit
import FormworkKit
import Foundation

@MainActor
enum SessionActivity {
    static func sync(_ session: Session?) {
        guard let session, session.isActive, let state = state(for: session) else {
            end()
            return
        }

        if Activity<SessionActivityAttributes>.activities.isEmpty {
            start(session, state: state)
        } else {
            Task {
                await push(state)
            }
        }
    }

    static func end() {
        Task {
            await stop()
        }
    }

    private nonisolated static func push(_ state: SessionActivityAttributes.ContentState) async {
        let content = ActivityContent(state: state, staleDate: nil)

        for activity in Activity<SessionActivityAttributes>.activities {
            await activity.update(content)
        }
    }

    private nonisolated static func stop() async {
        for activity in Activity<SessionActivityAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
    }

    static func state(for session: Session) -> SessionActivityAttributes.ContentState? {
        guard let current = session.current else {
            return nil
        }

        return SessionActivityAttributes.ContentState(
            title: current.title,
            subtitle: current.subtitle,
            pictogram: current.pictogram,
            status: current.status.isPending ? nil : current.status.pictogram,
            resolved: session.history.count,
            total: session.entries.count,
            isPending: current.status.isPending,
            isComplete: session.isComplete,
            canMoveForward: session.next != nil,
            canMoveBackward: session.previous != nil
        )
    }

    private static func start(_ session: Session, state: SessionActivityAttributes.ContentState) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            return
        }

        let attributes = SessionActivityAttributes(
            workout: session.workout?.title ?? String(localized: .unknown),
            started: session.started
        )

       
        _ = try? Activity<SessionActivityAttributes>.request(
            attributes: attributes,
            content: ActivityContent(state: state, staleDate: nil)
        )
    }
}
