//
//  SessionActivity.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 06.09.26.
//

import ActivityKit

public enum SessionActivity {
    /// Shows the given state in the Live Activity, starting one if needed, or ends it when there is no state.
    public static func sync(_ state: SessionActivityAttributes.ContentState?) async {
        let activities = Activity<SessionActivityAttributes>.activities

        guard let state else {
            for activity in activities {
                await activity.end(nil, dismissalPolicy: .immediate)
            }

            return
        }

        let content = ActivityContent(state: state, staleDate: nil)

        if let activity = activities.first {
            await activity.update(content)
        } else {
            _ = try? Activity.request(attributes: SessionActivityAttributes(), content: content)
        }
    }
}
