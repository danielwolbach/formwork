//
//  Reminders.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 05.10.26.
//

import Foundation
import UserNotifications

public struct Reminder: Hashable, Sendable {
    public enum Kind: Hashable, Sendable {
        case daily(workouts: [String])
        case upcoming(workout: String)
    }

    public let date: Date

    public let kind: Kind
}

public struct ReminderOptions: Equatable, Sendable {
    public static let lead = 30

    public static let defaultDailyMinute = 8 * 60

    static let minimumSessions = 3

    static let limit = 64

    public var dailyMinute: Int?

    public var isUpcomingEnabled: Bool

    public init(dailyMinute: Int?, isUpcomingEnabled: Bool) {
        self.dailyMinute = dailyMinute
        self.isUpcomingEnabled = isUpcomingEnabled
    }
}

@MainActor
public enum Reminders {
    public static func sync(_ workouts: [Workout], options: ReminderOptions) {
        let reminders = workouts.reminders(options)
        let center = UNUserNotificationCenter.current()

        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()

        // Added even without permission, so they start firing once it is granted.
        for (index, reminder) in reminders.enumerated() {
            center.add(request(for: reminder, identifier: "\(index)"))
        }

        guard !reminders.isEmpty else {
            return
        }

        Task {
            if await center.notificationSettings().authorizationStatus == .notDetermined {
                _ = try? await center.requestAuthorization(options: [.alert, .sound])
            }
        }
    }

    private static func request(for reminder: Reminder, identifier: String) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.sound = .default

        switch reminder.kind {
        case let .daily(workouts):
            content.title = String(localized: .reminderDailyTitle)
            content.body = workouts.formatted(.list(type: .and))
        case let .upcoming(workout):
            content.title = workout
            content.body = String(localized: .reminderUpcomingMessage(minutes: ReminderOptions.lead))
        }

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminder.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        return UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
    }
}

extension [Workout] {
    func reminders(_ options: ReminderOptions, now: Date = .now, in calendar: Calendar = .current) -> [Reminder] {
        let workouts = filter { !$0.isArchived }
        let lastSessions = workouts.reduce(into: [:]) { $0[$1] = $1.lastSession(in: calendar) }
        let startMinutes = workouts.reduce(into: [Workout: Int]()) { result, workout in
            if workout.sessions.count(where: { !$0.isActive }) >= ReminderOptions.minimumSessions {
                result[workout] = workout.typicalStartMinute(in: calendar)
            }
        }
        let today = calendar.startOfDay(for: now)
        var reminders: [Reminder] = []

        // As many days as the queue holds reminders; the next launch tops it up again.
        for offset in 0 ..< ReminderOptions.limit {
            guard let day = calendar.date(byAdding: .day, value: offset, to: today) else {
                continue
            }

            let due = workouts
                .filter { $0.schedule.isDue(on: day, after: lastSessions[$0], now: now, in: calendar) }
                .sorted(using: SortDescriptor(\.name, comparator: .localizedStandard))

            guard !due.isEmpty else {
                continue
            }

            let daily = options.dailyMinute.flatMap { date(at: $0, on: day, in: calendar) }

            if let daily, daily > now {
                reminders.append(Reminder(date: daily, kind: .daily(workouts: due.map(\.name))))
            }

            guard options.isUpcomingEnabled else {
                continue
            }

            for workout in due {
                guard
                    let start = startMinutes[workout],
                    let upcoming = date(at: start - ReminderOptions.lead, on: day, in: calendar),
                    upcoming > now
                else {
                    continue
                }

                // Too close to the daily reminder, or before it, it would only ping twice in a row.
                if let daily, upcoming < daily.addingTimeInterval(TimeInterval(ReminderOptions.lead * 60)) {
                    continue
                }

                reminders.append(Reminder(date: upcoming, kind: .upcoming(workout: workout.name)))
            }
        }

        return [Reminder](reminders.sorted { $0.date < $1.date }.prefix(ReminderOptions.limit))
    }
}

private func date(at minute: Int, on day: Date, in calendar: Calendar) -> Date? {
    guard (0 ..< 24 * 60).contains(minute) else {
        return nil
    }

    return calendar.date(bySettingHour: minute / 60, minute: minute % 60, second: 0, of: day)
}
