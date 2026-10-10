//
//  SessionActivity.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 06.09.26.
//

import ActivityKit
import OSLog

public enum SessionActivity {
    public static func sync(_ state: SessionActivityAttributes.ContentState?) async {
        let activities = Activity<SessionActivityAttributes>.activities

        guard let state else {
            for activity in activities {
                await activity.end(nil, dismissalPolicy: .immediate)
                Logger.session.info("Ended live activity")
            }

            return
        }

        let content = ActivityContent(state: state, staleDate: nil)

        if let activity = activities.first {
            await activity.update(content)
        } else {
            do {
                _ = try Activity.request(attributes: SessionActivityAttributes(), content: content)
                Logger.session.info("Started live activity")
            } catch {
                Logger.session.error("Starting live activity failed: \(error, privacy: .public)")
            }
        }
    }
}
