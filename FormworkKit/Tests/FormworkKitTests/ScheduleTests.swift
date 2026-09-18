//
//  ScheduleTests.swift
//  FormworkKitTests
//
//  Created by Daniel Wolbach on 18.09.26.
//

@testable import FormworkKit
import Foundation
import Testing

struct ScheduleTests {
    private static func calendar(firstWeekday: Int = 1) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US")
        calendar.firstWeekday = firstWeekday
        return calendar
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

    @Test func symbolMatchesCalendar() {
        let calendar = Self.calendar()

        #expect(Schedule.Weekday.monday.symbol(in: calendar) == "M")
        #expect(Schedule.Weekday.sunday.symbol(in: calendar) == "S")
    }
}
