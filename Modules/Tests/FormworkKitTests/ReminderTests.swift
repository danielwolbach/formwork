//
//  ReminderTests.swift
//  FormworkKitTests
//
//  Created by Daniel Wolbach on 05.10.26.
//

@testable import FormworkKit
import Foundation
import SwiftData
import Testing

@MainActor
struct ReminderTests {
    private let calendar = Calendar.current

    private let today = Calendar.current.startOfDay(for: .now)

    @Test
    func dailyRemindsOnEachPlannedDay() throws {
        let store = try TestStore()
        store.workout.schedule = .daily(days: 2, anchor: today)

        let reminders = try [store.workout].reminders(ReminderOptions(dailyMinute: 8 * 60, isUpcomingEnabled: false), now: date(day: 0, hour: 6), in: calendar)

        #expect(reminders.count == ReminderOptions.limit / 2)
        #expect(try reminders.prefix(2).map(\.date) == [date(day: 0, hour: 8), date(day: 2, hour: 8)])
        #expect(reminders.first?.kind == .daily(workouts: ["Full Body"]))
    }

    @Test
    func dailyGroupsTheWorkoutsOfADay() throws {
        let store = try TestStore()
        store.workout.schedule = .daily(anchor: today)
        let other = Workout(name: "Arms", pictogram: store.workout.pictogram, schedule: .daily(anchor: today), entries: [])
        store.context.insert(other)

        let reminders = try [store.workout, other].reminders(ReminderOptions(dailyMinute: 8 * 60, isUpcomingEnabled: false), now: date(day: 0, hour: 6), in: calendar)

        #expect(reminders.first?.kind == .daily(workouts: ["Arms", "Full Body"]))
    }

    @Test
    func dailySkipsATimeThatHasPassed() throws {
        let store = try TestStore()
        store.workout.schedule = .daily(anchor: today)

        let reminders = try [store.workout].reminders(ReminderOptions(dailyMinute: 8 * 60, isUpcomingEnabled: false), now: date(day: 0, hour: 9), in: calendar)

        #expect(try reminders.first?.date == date(day: 1, hour: 8))
    }

    @Test
    func aWorkoutDoneTodayIsNotRemindedToday() throws {
        let store = try TestStore()
        store.workout.schedule = .daily(anchor: today)

        let session = Session(workout: store.workout)
        store.context.insert(session)
        session.startDate = try date(day: 0, hour: 6)
        session.endDate = session.startDate

        let reminders = try [store.workout].reminders(ReminderOptions(dailyMinute: 8 * 60, isUpcomingEnabled: false), now: date(day: 0, hour: 7), in: calendar)

        #expect(try reminders.first?.date == date(day: 1, hour: 8))
    }

    @Test
    func archivedWorkoutsAreNotReminded() throws {
        let store = try TestStore()
        store.workout.schedule = .daily(anchor: today)
        store.workout.isArchived = true

        #expect(try [store.workout].reminders(ReminderOptions(dailyMinute: 8 * 60, isUpcomingEnabled: true), now: date(day: 0, hour: 6), in: calendar).isEmpty)
    }

    @Test(arguments: [(0, false), (1, true)])
    func upcomingNeedsARecentSession(history: Int, expected: Bool) throws {
        let store = try store(history: history)

        let reminders = try [store.workout].reminders(ReminderOptions(dailyMinute: nil, isUpcomingEnabled: true), now: date(day: 0, hour: 6), in: calendar)

        #expect(try (reminders.first?.date == date(day: 0, hour: 17, minute: 30)) == expected)
    }

    @Test
    func upcomingIgnoresSessionsBeforeTheRecentWeeks() throws {
        let store = try store(history: 0)
        let session = Session(workout: store.workout)
        store.context.insert(session)
        session.startDate = try date(day: -History.recentWeeks * 7, hour: 18)
        session.endDate = session.startDate

        let reminders = try [store.workout].reminders(ReminderOptions(dailyMinute: nil, isUpcomingEnabled: true), now: date(day: 0, hour: 6), in: calendar)

        #expect(reminders.isEmpty)
    }

    @Test
    func upcomingRemindsBeforeTheTypicalStart() throws {
        let store = try store(history: 3)

        let reminders = try [store.workout].reminders(ReminderOptions(dailyMinute: 8 * 60, isUpcomingEnabled: true), now: date(day: 0, hour: 6), in: calendar)

        #expect(try reminders.prefix(2) == [
            Reminder(date: date(day: 0, hour: 8), kind: .daily(workouts: ["Full Body"])),
            Reminder(date: date(day: 0, hour: 17, minute: 30), kind: .upcoming(workout: "Full Body")),
        ])
    }

    @Test(arguments: [(8, 15), (7, 0)])
    func upcomingYieldsToANearbyDailyReminder(hour: Int, minute: Int) throws {
        let store = try store(history: 3, hour: hour, minute: minute)

        let reminders = try [store.workout].reminders(ReminderOptions(dailyMinute: 8 * 60, isUpcomingEnabled: true), now: date(day: 0, hour: 6), in: calendar)

        #expect(reminders.allSatisfy { $0.kind == .daily(workouts: ["Full Body"]) })
    }

    @Test
    func remindersStopAtTheLimit() throws {
        let store = try store(history: 3)

        let reminders = try [store.workout].reminders(ReminderOptions(dailyMinute: 8 * 60, isUpcomingEnabled: true), now: date(day: 0, hour: 6), in: calendar)

        #expect(reminders.count == ReminderOptions.limit)
        #expect(try reminders.last?.date == date(day: ReminderOptions.limit / 2 - 1, hour: 17, minute: 30))
    }

    private func date(day: Int, hour: Int, minute: Int = 0) throws -> Date {
        let day = try #require(calendar.date(byAdding: .day, value: day, to: today))
        return try #require(calendar.date(bySettingHour: hour, minute: minute, second: 0, of: day))
    }

    /// An every-day schedule with finished sessions on the days before today, all starting at the given time.
    private func store(history: Int, hour: Int = 18, minute: Int = 0) throws -> TestStore {
        let store = try TestStore()
        store.workout.schedule = try .daily(days: 1, anchor: date(day: -10, hour: 0))

        for day in stride(from: -history, to: 0, by: 1) {
            let session = Session(workout: store.workout)
            store.context.insert(session)
            session.startDate = try date(day: day, hour: hour, minute: minute)
            session.endDate = session.startDate
        }

        return store
    }
}
