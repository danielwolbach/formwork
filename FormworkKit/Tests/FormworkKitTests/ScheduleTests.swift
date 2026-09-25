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
        (1, [Schedule.Weekday.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]),
        (2, [Schedule.Weekday.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]),
        (7, [Schedule.Weekday.saturday, .sunday, .monday, .tuesday, .wednesday, .thursday, .friday]),
    ])
    func orderedStartsOnFirstWeekday(firstWeekday: Int, expected: [Schedule.Weekday]) {
        #expect(Schedule.Weekday.ordered(in: Self.calendar(firstWeekday: firstWeekday)) == expected)
    }

    @Test(arguments: zip(
        Schedule.Weekday.allCases,
        ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    ))
    func nameMatchesCalendar(weekday: Schedule.Weekday, name: String) {
        #expect(weekday.name(in: Self.calendar()) == name)
    }

    @Test(arguments: zip(
        Schedule.Weekday.allCases,
        [2, 3, 4, 5, 6, 7, 1]
    ))
    func calendarNumberMatchesCalendar(weekday: Schedule.Weekday, number: Int) {
        #expect(weekday.calendarNumber == number)
        #expect(Schedule.Weekday(calendarNumber: number) == weekday)
    }

    @Test
    func symbolMatchesCalendar() {
        let calendar = Self.calendar()

        #expect(Schedule.Weekday.monday.symbol(in: calendar) == "M")
        #expect(Schedule.Weekday.sunday.symbol(in: calendar) == "S")
    }

    @Test(arguments: [
        (0, true),
        (7, false),
        (14, true),
        (28, true),
        (1, false),
        (-14, false),
    ])
    func weeklyRepeatsEveryIntervalWeeks(offset: Int, expected: Bool) {
        let schedule = Schedule.weekly(weekdays: Schedule.Weekdays([.monday]), interval: 2, anchor: Self.day(7))

        #expect(schedule.isScheduled(on: Self.day(7 + offset), in: Self.calendar()) == expected)
    }

    @Test
    func weeklySkipsWeekdaysBeforeTheAnchorInItsWeek() {
        let schedule = Schedule.weekly(weekdays: Schedule.Weekdays([.monday, .friday]), interval: 2, anchor: Self.day(9))

        #expect(!schedule.isScheduled(on: Self.day(7), in: Self.calendar()))
        #expect(schedule.isScheduled(on: Self.day(11), in: Self.calendar()))
        #expect(schedule.isScheduled(on: Self.day(21), in: Self.calendar()))
    }

    @Test(arguments: [
        (0, true),
        (1, false),
        (2, false),
        (3, true),
        (6, true),
        (-3, false),
    ])
    func dailyRepeatsEveryIntervalDays(offset: Int, expected: Bool) {
        let schedule = Schedule.daily(interval: 3, anchor: Self.day(7))

        #expect(schedule.isScheduled(on: Self.day(7 + offset), in: Self.calendar()) == expected)
    }

    @Test
    func inactiveIsNeverScheduled() {
        for day in 1 ... 14 {
            #expect(!Schedule.inactive.isScheduled(on: Self.day(day), in: Self.calendar()))
        }
    }

    @MainActor
    @Test(arguments: [
        Schedule.weekly(weekdays: Schedule.Weekdays([.monday, .thursday]), interval: 2, anchor: ScheduleTests.day(7)),
        Schedule.daily(interval: 3, anchor: ScheduleTests.day(9)),
    ])
    func persists(schedule: Schedule) throws {
        let store = try TestStore()
        store.workout.schedule = schedule
        try store.context.save()

        let workouts = try ModelContext(store.container).fetch(FetchDescriptor<Workout>())

        #expect(workouts.map(\.schedule) == [schedule])
    }
}
