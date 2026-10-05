//
//  ScheduleTests.swift
//  FormworkKitTests
//
//  Created by Daniel Wolbach on 18.09.26.
//

@testable import FormworkKit
import Foundation
import SwiftData
import Testing

struct ScheduleTests {
    private static let monday = Schedule.Weekdays(calendarWeekday: 2)

    private static let thursday = Schedule.Weekdays(calendarWeekday: 5)

    private static let friday = Schedule.Weekdays(calendarWeekday: 6)

    private static func calendar(firstWeekday: Int = 1) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US")
        calendar.firstWeekday = firstWeekday
        return calendar
    }

    /// A day in September 2026; the 7th is a Monday.
    private static func day(_ day: Int) -> Date {
        calendar().date(from: DateComponents(year: 2026, month: 9, day: day, hour: 12))!
    }

    @Test(arguments: [
        (1, [1, 2, 3, 4, 5, 6, 7]),
        (2, [2, 3, 4, 5, 6, 7, 1]),
        (7, [7, 1, 2, 3, 4, 5, 6]),
    ])
    func orderedWeekdaysStartOnFirstWeekday(firstWeekday: Int, expected: [Int]) {
        #expect(Self.calendar(firstWeekday: firstWeekday).orderedWeekdays == expected)
    }

    @Test(arguments: [
        (0, true),
        (7, true),
        (14, true),
        (1, false),
        (-7, false),
    ])
    func weeklyRepeatsEveryWeekFromTheAnchor(offset: Int, expected: Bool) {
        let schedule = Schedule.weekly(weekdays: Self.monday, anchor: Self.day(7))

        #expect(schedule.isScheduled(on: Self.day(7 + offset), after: nil, in: Self.calendar()) == expected)
    }

    @Test
    func weeklySkipsWeekdaysBeforeTheAnchorInItsWeek() {
        let schedule = Schedule.weekly(weekdays: [Self.monday, Self.friday], anchor: Self.day(9))

        #expect(!schedule.isScheduled(on: Self.day(7), after: nil, in: Self.calendar()))
        #expect(schedule.isScheduled(on: Self.day(11), after: nil, in: Self.calendar()))
        #expect(schedule.isScheduled(on: Self.day(14), after: nil, in: Self.calendar()))
    }

    @Test(arguments: [
        (-1, false),
        (0, true),
        (1, true),
        (5, true),
    ])
    func dailyStaysDueFromTheAnchorUntilItIsDone(offset: Int, expected: Bool) {
        let schedule = Schedule.daily(days: 3, anchor: Self.day(7))
        let day = Self.day(7 + offset)

        #expect(schedule.isScheduled(on: day, after: nil, now: day, in: Self.calendar()) == expected)
    }

    @Test(arguments: [
        (8, 8, false),
        (8, 10, false),
        (8, 11, true),
        (8, 13, true),
        (6, 8, false),
        (6, 9, true),
    ])
    func dailyFloatsFromTheLastSession(last: Int, day: Int, expected: Bool) {
        let schedule = Schedule.daily(days: 3, anchor: Self.day(7))

        #expect(schedule.isScheduled(on: Self.day(day), after: Self.day(last), now: Self.day(day), in: Self.calendar()) == expected)
    }

    @Test
    func dailyWaitsForAnAnchorAfterTheLastSession() {
        let schedule = Schedule.daily(days: 3, anchor: Self.day(20))

        #expect(!schedule.isScheduled(on: Self.day(19), after: Self.day(8), now: Self.day(19), in: Self.calendar()))
        #expect(schedule.isScheduled(on: Self.day(20), after: Self.day(8), now: Self.day(20), in: Self.calendar()))
    }

    @Test(arguments: [
        (14, true),
        (15, false),
        (16, false),
        (17, true),
        (20, true),
    ])
    func dailyProjectsLaterDaysFromAnOverdueToday(day: Int, expected: Bool) {
        let schedule = Schedule.daily(days: 3, anchor: Self.day(7))

        #expect(schedule.isScheduled(on: Self.day(day), after: Self.day(8), now: Self.day(14), in: Self.calendar()) == expected)
    }

    @Test(arguments: [
        (9, false),
        (10, false),
        (11, true),
        (12, false),
        (14, true),
    ])
    func dailyProjectsLaterDaysFromTheNextDueDay(day: Int, expected: Bool) {
        let schedule = Schedule.daily(days: 3, anchor: Self.day(7))

        #expect(schedule.isScheduled(on: Self.day(day), after: Self.day(8), now: Self.day(9), in: Self.calendar()) == expected)
    }

    @Test
    func weeklyIsNotDueOnTheDayOfTheLastSession() {
        let schedule = Schedule.weekly(weekdays: Self.monday, anchor: Self.day(7))

        #expect(schedule.isScheduled(on: Self.day(14), after: Self.day(14), in: Self.calendar()))
        #expect(!schedule.isDue(on: Self.day(14), after: Self.day(14), in: Self.calendar()))
        #expect(schedule.isDue(on: Self.day(14), after: Self.day(8), in: Self.calendar()))
    }

    @Test
    func inactiveIsNeverScheduled() {
        for day in 1 ... 14 {
            #expect(!Schedule.inactive.isScheduled(on: Self.day(day), after: nil, in: Self.calendar()))
        }
    }

    @MainActor
    @Test(arguments: [Schedule.today(), Schedule.daily()])
    func aWorkoutDoneTodayIsNoLongerPending(schedule: Schedule) throws {
        let store = try TestStore()
        store.workout.schedule = schedule

        #expect([store.workout].pending() == [store.workout])

        let session = Session(workout: store.workout)
        store.container.mainContext.insert(session)
        session.startDate = .now

        #expect([store.workout].pending() == [store.workout])

        session.endDate = .now

        #expect([store.workout].pending().isEmpty)
        #expect(store.workout.isScheduled())
    }

    @MainActor
    @Test
    func aWorkoutDoneOnARestDayWasNotPlanned() throws {
        let store = try TestStore()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        store.workout.schedule = try .daily(days: 3, anchor: #require(calendar.date(byAdding: .day, value: -7, to: today)))

        for offset in [-1, 0] {
            let session = Session(workout: store.workout)
            store.container.mainContext.insert(session)
            session.startDate = try #require(calendar.date(byAdding: .day, value: offset, to: today))
            session.endDate = session.startDate
        }

        #expect(!store.workout.isDue())
        #expect(!store.workout.isScheduled())
    }

    @MainActor
    @Test(arguments: [
        Schedule.weekly(weekdays: [ScheduleTests.monday, ScheduleTests.thursday], anchor: ScheduleTests.day(7)),
        Schedule.daily(days: 3, anchor: ScheduleTests.day(9)),
    ])
    func persists(schedule: Schedule) throws {
        let store = try TestStore()
        store.workout.schedule = schedule
        try store.context.save()

        let workouts = try ModelContext(store.container).fetch(FetchDescriptor<Workout>())

        #expect(workouts.map(\.schedule) == [schedule])
    }
}
