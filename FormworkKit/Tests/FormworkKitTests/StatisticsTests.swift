//
//  StatisticsTests.swift
//  FormworkKitTests
//
//  Created by Daniel Wolbach on 18.09.26.
//

@testable import FormworkKit
import Foundation
import Testing

extension Calendar {
    /// A Gregorian calendar in Berlin with weeks starting on Monday unless stated otherwise.
    static func berlin(firstWeekday: Int = 2) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Berlin")!
        calendar.firstWeekday = firstWeekday
        return calendar
    }

    func date(_ day: Int, month: Int = 9, year: Int = 2026, hour: Int = 12, minute: Int = 0) throws -> Date {
        try #require(date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute)))
    }
}

extension TestStore {
    /// A finished session, started at the given wall-clock time in `zone`. `perform` resolves its entries.
    @discardableResult
    func session(
        _ day: Int,
        month: Int = 9,
        hour: Int = 8,
        minute: Int = 0,
        minutes duration: Int = 60,
        zone: String = "Europe/Berlin",
        perform: (Session) -> Void = { _ in }
    ) throws -> Session {
        var local = Calendar.berlin()
        local.timeZone = try #require(TimeZone(identifier: zone))
        let started = try local.date(day, month: month, hour: hour, minute: minute)

        let session = try startSession()
        perform(session)
        session.started = started
        session.ended = started.addingTimeInterval(TimeInterval(duration * 60))
        session.timeZoneIdentifier = zone
        return session
    }
}

// MARK: - Statistic

struct StatisticTests {
    @Test func missingValueHasNoSubtitle() {
        let statistic = Statistic<Date>.lastCompleted(nil)

        #expect(statistic.value == nil)
        #expect(statistic.subtitle == nil)
        #expect(statistic.title == String(localized: .statisticLastCompletedTitle))
        #expect(statistic.pictogram == .date)
    }

    @Test func valueIsFormattedAsSubtitle() {
        #expect(Statistic<Int>.completions(3).subtitle == "3")
    }

    @Test(arguments: [
        (ExerciseTarget.weight(target: .init(weight: Quantity(100, in: .kilograms), sets: 3, reps: 10)), Quantity(100, in: .kilograms).formatted),
        (ExerciseTarget.bodyweight(target: .init(sets: 3, reps: 12)), String(localized: .exerciseTargetRepsTitle(12))),
        (ExerciseTarget.duration(target: .init(duration: Quantity(10, in: .minutes))), Quantity(10, in: .minutes).formatted),
        (ExerciseTarget.distance(target: .init(distance: Quantity(5, in: .kilometers))), Quantity(5, in: .kilometers).formatted),
    ])
    func personalBestShowsOnlyTheRank(target: ExerciseTarget, expected: String) {
        #expect(Statistic<ExerciseTarget>.personalBest(target).subtitle == expected)
    }

    @Test(arguments: [(1, "1 Rep"), (12, "12 Reps")])
    func repsArePluralized(count: Int, expected: String) {
        var resource = LocalizedStringResource.exerciseTargetRepsTitle(count)
        resource.locale = Locale(identifier: "en")

        #expect(String(localized: resource) == expected)
    }
}

// MARK: - Intervals

struct DateIntervalTests {
    let calendar = Calendar.berlin()

    @Test func monthRunsFromMidnightOnTheFirstToTheNextMonth() throws {
        let interval = DateInterval.month(9, year: 2026, calendar: calendar)

        #expect(try interval.start == calendar.date(1, month: 9, hour: 0))
        #expect(try interval.end == calendar.date(1, month: 10, hour: 0))
    }

    @Test func decemberEndsInTheNextYear() throws {
        let interval = DateInterval.month(12, year: 2026, calendar: calendar)

        #expect(try interval.end == calendar.date(1, month: 1, year: 2027, hour: 0))
    }

    @Test(arguments: [(2027, 28), (2028, 29)])
    func februaryRespectsLeapYears(year: Int, days: Int) {
        let interval = DateInterval.month(2, year: year, calendar: calendar)

        #expect(calendar.dateComponents([.day], from: interval.start, to: interval.end).day == days)
    }

    @Test func monthFollowsDaylightSavingTime() throws {
        // Daylight saving time ends in October, so it's one hour longer than 31 days.
        let interval = DateInterval.month(10, year: 2026, calendar: calendar)

        #expect(interval.duration == TimeInterval(31 * 24 * 3600 + 3600))
    }

    @Test func monthBoundariesUseTheCalendarsTimeZone() throws {
        var tokyo = calendar
        tokyo.timeZone = try #require(TimeZone(identifier: "Asia/Tokyo"))

        let berlin = DateInterval.month(9, year: 2026, calendar: calendar)
        let japan = DateInterval.month(9, year: 2026, calendar: tokyo)

        #expect(berlin.start.timeIntervalSince(japan.start) == 7 * 3600)
    }

    @Test func yearRunsFromNewYearToNewYear() throws {
        let interval = DateInterval.year(2026, calendar: calendar)

        #expect(try interval.start == calendar.date(1, month: 1, hour: 0))
        #expect(try interval.end == calendar.date(1, month: 1, year: 2027, hour: 0))
    }

    @Test func yearDefaultsToTheCurrentOne() {
        let year = calendar.component(.year, from: .now)

        #expect(DateInterval.year(calendar: calendar) == .year(year, calendar: calendar))
        #expect(DateInterval.month(3, calendar: calendar) == .month(3, year: year, calendar: calendar))
    }

    @Test func untilContainsEverythingBeforeTheEnd() throws {
        let end = try calendar.date(14)
        let interval = DateInterval.until(end)

        #expect(interval.start == .distantPast)
        // `DateInterval` stores a duration, so the end is only accurate to a few microseconds.
        #expect(abs(interval.end.timeIntervalSince(end)) < 0.001)
    }
}

// MARK: - Wall-clock time

@MainActor
struct WallClockTests {
    let store: TestStore
    let calendar = Calendar.berlin()

    init() throws {
        self.store = try TestStore()
    }

    @Test func sameTimeZoneKeepsTheExactDate() throws {
        let session = try store.session(14)
        session.started = Date(timeIntervalSinceReferenceDate: 811_531_182.447_183)

        #expect(session.localStarted(in: calendar) == session.started)
    }

    @Test func datesKeepTheClockTimeTheyWereRecordedAt() throws {
        let session = try store.session(14, hour: 8, zone: "America/New_York")
        let started = session.localStarted(in: calendar)
        let ended = try #require(session.localEnded(in: calendar))

        #expect(calendar.dateComponents([.day, .hour, .minute], from: started) == DateComponents(day: 14, hour: 8, minute: 0))
        #expect(calendar.dateComponents([.day, .hour, .minute], from: ended) == DateComponents(day: 14, hour: 9, minute: 0))
    }

    @Test func conversionKeepsFractionalSeconds() throws {
        let session = try store.session(14, zone: "America/New_York")
        session.started = session.started.addingTimeInterval(0.25)

        #expect(session.localStarted(in: calendar).timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 1) == 0.25)
    }

    @Test func runningSessionHasNoLocalEnd() throws {
        let session = try store.startSession()

        #expect(session.localEnded(in: calendar) == nil)
    }

    @Test func unknownTimeZoneFallsBackToTheCurrentOne() throws {
        let session = try store.session(14)
        session.timeZoneIdentifier = "Nowhere/Invalid"

        #expect(session.timeZone == .current)
    }
}

// MARK: - Overall

@MainActor
struct OverallStatisticsTests {
    let store: TestStore
    let calendar = Calendar.berlin()

    init() throws {
        self.store = try TestStore()
    }

    func statistics(until end: Date, calendar: Calendar? = nil) -> OverallStatistics {
        OverallStatistics(sessions: store.workout.sessions, interval: .until(end), calendar: calendar ?? self.calendar)
    }

    func statistics(in interval: DateInterval) -> OverallStatistics {
        OverallStatistics(sessions: store.workout.sessions, interval: interval, calendar: calendar)
    }

    @Test func withoutSessionsThereIsNoStreak() throws {
        let statistics = try statistics(until: calendar.date(16))

        #expect(statistics.weekStreak.value == 0)
        #expect(statistics.longestWeekStreak.value == 0)
        #expect(statistics.lastSession.value == nil)
    }

    @Test func unfinishedWeekDoesNotBreakTheStreak() throws {
        // Weeks of Aug 24, Aug 31 and Sep 7. Nothing yet in the week of Sep 14.
        try store.session(25, month: 8)
        try store.session(1)
        try store.session(9)

        #expect(try statistics(until: calendar.date(16)).weekStreak.value == 3)

        try store.session(15)

        #expect(try statistics(until: calendar.date(16)).weekStreak.value == 4)
    }

    @Test func emptyWeekBreaksTheStreak() throws {
        try store.session(1)
        try store.session(3)

        #expect(try statistics(until: calendar.date(16)).weekStreak.value == 0)
    }

    @Test func severalSessionsInOneWeekCountOnce() throws {
        for day in [7, 8, 9, 14] {
            try store.session(day)
        }

        #expect(try statistics(until: calendar.date(16)).weekStreak.value == 2)
    }

    @Test func runningSessionDoesNotCount() throws {
        try store.session(9)
        let running = try store.startSession()
        running.started = try calendar.date(15, hour: 8)

        #expect(try statistics(until: calendar.date(16)).weekStreak.value == 1)
    }

    @Test func sessionsFinishedAfterTheEndAreIgnored() throws {
        try store.session(9)
        try store.session(15, hour: 11) // Ends at noon, exactly at the cutoff.
        try store.session(15, hour: 11, minute: 30) // Started before, but ends after the cutoff.

        let statistics = try statistics(until: calendar.date(15))

        #expect(statistics.weekStreak.value == 2)
        #expect(try statistics.lastSession.value == calendar.date(15))
    }

    @Test(arguments: [(2, 2), (1, 1)])
    func weeksStartOnTheCalendarsFirstWeekday(firstWeekday: Int, streak: Int) throws {
        // Sunday Sep 6 and Saturday Sep 12 are in different weeks when weeks start on Monday,
        // and in the same week when they start on Sunday.
        try store.session(6)
        try store.session(12)

        let calendar = Calendar.berlin(firstWeekday: firstWeekday)

        #expect(try statistics(until: calendar.date(13), calendar: calendar).weekStreak.value == streak)
    }

    @Test func streakSurvivesDaylightSavingTimeChanges() throws {
        // Daylight saving time ends on Sunday, Oct 25.
        try store.session(20, month: 10)
        try store.session(25, month: 10, hour: 22)
        try store.session(27, month: 10)
        try store.session(3, month: 11)

        #expect(try statistics(until: calendar.date(4, month: 11)).weekStreak.value == 3)
    }

    @Test func sessionsAreDatedByTheirRecordedTimeZone() throws {
        // Sunday 23:00 in New York is already Monday in Berlin, but it belongs to the week it was recorded in.
        try store.session(13, hour: 23, zone: "America/New_York")
        try store.session(7)

        #expect(try statistics(until: calendar.date(16)).weekStreak.value == 1)
    }

    @Test func longestStreakIsMeasuredWithinTheInterval() throws {
        // Weeks of Aug 24, Aug 31 and Sep 7, a gap, then the week of Sep 21.
        try store.session(24, month: 8)
        try store.session(1)
        try store.session(7)
        try store.session(22)

        let statistics = try statistics(in: #require(calendar.dateInterval(of: .month, for: calendar.date(10))))

        #expect(statistics.longestWeekStreak.value == 2)
        #expect(statistics.weekStreak.value == 1)
    }

    @Test func currentStreakIncludesHistoryBeforeTheInterval() throws {
        try store.session(1)
        try store.session(7)
        try store.session(15)

        let statistics = try statistics(in: DateInterval(start: calendar.date(14, hour: 0), end: calendar.date(16)))

        #expect(statistics.weekStreak.value == 3)
        #expect(statistics.longestWeekStreak.value == 1)
    }

    @Test func intervalIsHalfOpen() throws {
        // Starts exactly at midnight on Oct 1, so it belongs to October only.
        try store.session(1, month: 10, hour: 0)

        let september = try #require(calendar.dateInterval(of: .month, for: calendar.date(10)))
        let october = try #require(calendar.dateInterval(of: .month, for: calendar.date(10, month: 10)))

        #expect(statistics(in: september).lastSession.value == nil)
        #expect(statistics(in: october).lastSession.value != nil)
    }
}

// MARK: - Workout

@MainActor
struct WorkoutStatisticsTests {
    let store: TestStore
    let calendar = Calendar.berlin()

    init() throws {
        self.store = try TestStore()
    }

    func statistics(in interval: DateInterval = .until(.distantFuture)) -> WorkoutStatistics {
        WorkoutStatistics(workout: store.workout, interval: interval, calendar: calendar)
    }

    @Test func workoutWithoutSessionsHasNoValues() {
        let statistics = statistics()

        #expect(statistics.lastCompleted.value == nil)
        #expect(statistics.completions.value == 0)
        #expect(statistics.completionRate.value == nil)
        #expect(statistics.typicalDuration.value == nil)
        #expect(statistics.typicalStartTime.value == nil)
        #expect(statistics.mostSkippedExercise.value == nil)
    }

    @Test func countsFinishedSessionsAndMostSkippedExercise() throws {
        for day in [7, 8] {
            try store.session(day) { session in
                session.completeAndAdvance()
                session.skipAndAdvance()
            }
        }
        _ = try store.startSession()

        let statistics = statistics()

        #expect(statistics.completions.value == 2)
        #expect(statistics.mostSkippedExercise.subtitle == "Bench Press")
        #expect(try statistics.lastCompleted.value == calendar.date(8, hour: 9))
    }

    @Test func completionRateCoversEveryExerciseOfFinishedSessions() throws {
        try store.session(7) { session in
            session.completeAndAdvance()
            session.completeAndAdvance()
            session.completeAndAdvance()
        }
        try store.session(8) { session in
            session.completeAndAdvance()
            session.skipAndAdvance()
        }
        let running = try store.startSession()
        running.skipAndAdvance()

        // 3 of 3, then 1 of 3 with one skipped and one left pending. The running session doesn't count.
        #expect(statistics().completionRate.value == 4.0 / 6.0)
    }

    @Test func typicalDurationIsTheMedian() throws {
        for (day, minutes) in [(7, 30), (8, 60), (9, 120)] {
            try store.session(day, minutes: minutes)
        }

        #expect(statistics().typicalDuration.value == .seconds(3600))
    }

    @Test func typicalStartTimeIsTheMedianClockTime() throws {
        for (day, hour, minute) in [(7, 7, 0), (8, 8, 15), (9, 19, 30)] {
            try store.session(day, hour: hour, minute: minute)
        }

        #expect(statistics().typicalStartTime.value == DateComponents(hour: 8, minute: 15))
    }

    @Test func typicalStartTimeUsesTheRecordedTimeZone() throws {
        // 08:00 in New York is 14:00 in Berlin, but the user saw 08:00.
        try store.session(7, hour: 8)
        try store.session(8, hour: 8, zone: "America/New_York")

        #expect(statistics().typicalStartTime.value == DateComponents(hour: 8, minute: 0))
    }

    @Test func onlySessionsWithinTheIntervalCount() throws {
        try store.session(31, month: 8)
        try store.session(7)
        try store.session(14)
        try store.session(1, month: 10)

        let statistics = try statistics(in: #require(calendar.dateInterval(of: .month, for: calendar.date(10))))

        #expect(statistics.completions.value == 2)
        #expect(try statistics.lastCompleted.value == calendar.date(14, hour: 9))
    }
}

// MARK: - Exercise

@MainActor
struct ExerciseStatisticsTests {
    let store: TestStore
    let squat: Exercise
    let calendar = Calendar.berlin()

    init() throws {
        self.store = try TestStore()
        self.squat = try #require(store.workout.entries.sorted().first?.exercise)
    }

    func statistics(in interval: DateInterval = .until(.distantFuture)) -> ExerciseStatistics {
        ExerciseStatistics(exercise: squat, interval: interval, calendar: calendar)
    }

    @Test func exerciseWithoutSessionsHasNoValues() {
        let statistics = statistics()

        #expect(statistics.lastCompleted.value == nil)
        #expect(statistics.completionRate.value == nil)
        #expect(statistics.personalBest.value == nil)
        #expect(statistics.completions.value == 0)
        #expect(statistics.completions.subtitle == "0")
    }

    @Test func onlyFinishedSessionsCount() throws {
        try store.session(7) { $0.completeAndAdvance() }
        let running = try store.startSession()
        running.skipAndAdvance()

        let statistics = statistics()

        #expect(statistics.completions.value == 1)
        #expect(statistics.completionRate.value == 1)
        #expect(statistics.lastCompleted.value != nil)
    }

    @Test func skippedEntriesLowerTheCompletionRate() throws {
        try store.session(7) { $0.completeAndAdvance() }
        try store.session(8) { $0.skipAndAdvance() }

        let statistics = statistics()

        #expect(statistics.completions.value == 1)
        #expect(statistics.completionRate.value == 0.5)
    }

    @Test func onlySessionsWithinTheIntervalCount() throws {
        try store.session(31, month: 8) { $0.completeAndAdvance() }
        try store.session(7) { $0.skipAndAdvance() }

        let statistics = try statistics(in: #require(calendar.dateInterval(of: .month, for: calendar.date(10))))

        #expect(statistics.completions.value == 0)
        #expect(statistics.completionRate.value == 0)
        #expect(statistics.personalBest.value == nil)
    }

    @Test func personalBestIgnoresTargetsOfAnotherType() throws {
        try store.session(7) { $0.completeAndAdvance() }

        #expect(statistics().personalBest.value?.bodyweightTarget == .init(sets: 3, reps: 10))

        squat.type = .weight

        #expect(statistics().personalBest.value == nil)
    }
}
