//
//  NotificationRouter.swift
//  FormworkModules
//
//  Created by Daniel Wolbach on 05.10.26.
//

import Observation
import UserNotifications

@MainActor
@Observable
public final class NotificationRouter: NSObject, UNUserNotificationCenterDelegate {
    public var isTapPending = false

    public nonisolated func userNotificationCenter(_: UNUserNotificationCenter, didReceive _: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        MainActor.assumeIsolated {
            isTapPending = true
        }
        completionHandler()
    }
}
