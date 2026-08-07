//
//  SessionActivityCoordinator.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 07.08.26.
//

@preconcurrency import ActivityKit
import Foundation

@MainActor
final class SessionActivityCoordinator {
    static func update(for session: Session) async {
        guard
            let activity = Activity<SessionActivityAttributes>.activities.first(where: {
                $0.attributes.sessionID == session.activity
            })
        else {
            return
        }

        await activity.update(content(for: session))
    }

    func synchronize(with session: Session?) async {
        let activities = Activity<SessionActivityAttributes>.activities

        guard let session else {
            for activity in activities {
                await activity.end(nil, dismissalPolicy: .immediate)
            }

            return
        }

        for activity in activities where activity.attributes.sessionID != session.activity {
            await activity.end(nil, dismissalPolicy: .immediate)
        }

        if activities.contains(where: { $0.attributes.sessionID == session.activity }) {
            await Self.update(for: session)
            return
        }

        await start(for: session)
    }

    private func start(for session: Session) async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            return
        }

        let attributes = SessionActivityAttributes(
            sessionID: session.activity,
            workoutName: session.workout?.name ?? "",
            started: session.started
        )

        do {
            _ = try Activity.request(
                attributes: attributes,
                content: Self.content(for: session),
                pushType: nil
            )
        } catch {
            // Ignore since Live Activities are optional and the in-app session control remains available.
        }
    }

    private static func content(for session: Session) -> ActivityContent<SessionActivityAttributes.ContentState> {
        ActivityContent(state: session.liveState, staleDate: nil)
    }
}

@MainActor
extension Session {
    var liveState: SessionActivityAttributes.ContentState {
        .init(
            exerciseName: current.title,
            subtitle: current.subtitle,
            completedCount: completed.count,
            totalCount: entries.count,
            entryStatus: Self.convertEntryStatus(from: current.status)
        )
    }

    static func convertEntryStatus(from status: SessionEntry.Status) -> SessionActivityAttributes.EntryStatus {
        switch status {
        case .pending: .pending
        case .done: .done
        case .skipped: .skipped
        }
    }
}
