//
//  StatisticsTests.swift
//  FormworkKitTests
//
//  Created by Daniel Wolbach on 18.09.26.
//

@testable import FormworkKit
import Foundation
import SwiftData
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

// MARK: - Metric

struct MetricTests {
    @Test
    func missingValueHasNoSubtitle() {
        let statistic = Metric<Date>.lastCompleted(nil, in: nil, calendar: .berlin())

        #expect(statistic.value == nil)
        #expect(statistic.subtitle == nil)
        #expect(statistic.title == String(localized: .statisticLastCompletedTitle))
        #expect(statistic.pictogram == .date)
    }

    @Test
    func valueIsFormattedAsSubtitle() {
        #expect(Metric<Int>.completions(3).subtitle == "3")
    }

    @Test
    func sessionsPerWeekShowAtMostOneDecimal() {
        #expect(Metric<Double>.sessionsPerWeek(2).subtitle == 2.0.formatted(.number.precision(.fractionLength(0 ... 1))))
        #expect(Metric<Double>.sessionsPerWeek(1.46).subtitle == 1.5.formatted(.number.precision(.fractionLength(0 ... 1))))
    }

    @Test
    func lastCompletedWithinAWeekIsRelative() throws {
        let date = try #require(Calendar.berlin().date(byAdding: .day, value: -2, to: .now))
        var style = Date.RelativeFormatStyle(presentation: .named, calendar: .berlin(), capitalizationContext: .beginningOfSentence)
        style.allowedFields = [.day]

        #expect(Metric<Date>.lastCompleted(date, in: nil, calendar: .berlin()).subtitle == date.formatted(style))
    }

    @Test
    func lastCompletedTodayIsTheDayAndNotTheHour() throws {
        // Two times on the same day, so neither may be shown as hours or minutes ago.
        let calendar = Calendar.berlin()
        let midnight = calendar.startOfDay(for: .now)
        let later = try #require(calendar.date(byAdding: .minute, value: 1, to: midnight))

        #expect(
            Metric<Date>.lastCompleted(midnight, in: nil, calendar: calendar).subtitle
                == Metric<Date>.lastCompleted(later, in: nil, calendar: calendar).subtitle
        )
    }

    @Test
    func lastCompletedEarlierIsItsDateInTheCalendar() throws {
        // 23:30 on May 28 in New York is already May 29 in Berlin.
        let calendar = Calendar.berlin()
        var newYork = calendar
        newYork.timeZone = try #require(TimeZone(identifier: "America/New_York"))
        let date = try newYork.date(28, month: 5, year: 2025, hour: 23, minute: 30)
        let style = Date.FormatStyle(calendar: calendar, timeZone: calendar.timeZone).day().month().year()

        let statistic = Metric<Date>.lastCompleted(date, in: nil, calendar: newYork)

        #expect(try statistic.subtitle == calendar.date(28, month: 5, year: 2025).formatted(style))
    }

    @Test
    func typicalStartTimeIsFormattedInTheCalendarsTimeZone() throws {
        var tokyo = Calendar.berlin(), newYork = Calendar.berlin()
        tokyo.timeZone = try #require(TimeZone(identifier: "Asia/Tokyo"))
        newYork.timeZone = try #require(TimeZone(identifier: "America/New_York"))
        let time = DateComponents(hour: 8, minute: 15)

        let subtitle = try #require(Metric<DateComponents>.typicalStartTime(time, calendar: tokyo).subtitle)

        #expect(subtitle == Metric<DateComponents>.typicalStartTime(time, calendar: newYork).subtitle)
    }

    @Test(arguments: [
        (ExerciseTarget.weight(target: .init(weight: Quantity(100, in: .kilograms), sets: 3, reps: 10)), Quantity(100, in: .kilograms).formatted),
        (ExerciseTarget.bodyweight(target: .init(sets: 3, reps: 12)), String(localized: .exerciseTargetRepsTitle(12))),
        (ExerciseTarget.duration(target: .init(duration: Quantity(10, in: .minutes))), Quantity(10, in: .minutes).formatted),
        (ExerciseTarget.distance(target: .init(distance: Quantity(5, in: .kilometers))), Quantity(5, in: .kilometers).formatted),
    ])
    func personalBestShowsOnlyTheRank(target: ExerciseTarget, expected: String) {
        #expect(Metric<ExerciseTarget>.personalBest(target).subtitle == expected)
    }

    @Test(arguments: [(1, "1 rep"), (12, "12 reps")])
    func repsArePluralized(count: Int, expected: String) {
        var resource = LocalizedStringResource.exerciseTargetRepsTitle(count)
        resource.locale = Locale(identifier: "en")

        #expect(String(localized: resource) == expected)
    }
}

// MARK: - Intervals

struct DateIntervalTests {
    let calendar = Calendar.berlin()

    @Test
    func monthRunsFromMidnightOnTheFirstToTheNextMonth() throws {
        let interval = DateInterval.month(9, year: 2026, calendar: calendar)

        #expect(try interval.start == calendar.date(1, month: 9, hour: 0))
        #expect(try interval.end == calendar.date(1, month: 10, hour: 0))
    }

    @Test
    func decemberEndsInTheNextYear() throws {
        let interval = DateInterval.month(12, year: 2026, calendar: calendar)

        #expect(try interval.end == calendar.date(1, month: 1, year: 2027, hour: 0))
    }

    @Test(arguments: [(2027, 28), (2028, 29)])
    func februaryRespectsLeapYears(year: Int, days: Int) {
        let interval = DateInterval.month(2, year: year, calendar: calendar)

        #expect(calendar.dateComponents([.day], from: interval.start, to: interval.end).day == days)
    }

    @Test
    func monthFollowsDaylightSavingTime() {
        // Daylight saving time ends in October, so it's one hour longer than 31 days.
        let interval = DateInterval.month(10, year: 2026, calendar: calendar)

        #expect(interval.duration == TimeInterval(31 * 24 * 3600 + 3600))
    }

    @Test
    func monthBoundariesUseTheCalendarsTimeZone() throws {
        var tokyo = calendar
        tokyo.timeZone = try #require(TimeZone(identifier: "Asia/Tokyo"))

        let berlin = DateInterval.month(9, year: 2026, calendar: calendar)
        let japan = DateInterval.month(9, year: 2026, calendar: tokyo)

        #expect(berlin.start.timeIntervalSince(japan.start) == 7 * 3600)
    }

    @Test
    func yearRunsFromNewYearToNewYear() throws {
        let interval = DateInterval.year(2026, calendar: calendar)

        #expect(try interval.start == calendar.date(1, month: 1, hour: 0))
        #expect(try interval.end == calendar.date(1, month: 1, year: 2027, hour: 0))
    }

    @Test
    func yearDefaultsToTheCurrentOne() {
        let year = calendar.component(.year, from: .now)

        #expect(DateInterval.year(calendar: calendar) == .year(year, calendar: calendar))
        #expect(DateInterval.month(3, calendar: calendar) == .month(3, year: year, calendar: calendar))
    }

    @Test
    func allTimeRunsFromTheDistantPastToTheDistantFuture() {
        #expect(DateInterval.allTime.start == .distantPast)
        // `DateInterval` stores a duration, so the end is only accurate to a few microseconds.
        #expect(abs(DateInterval.allTime.end.timeIntervalSince(.distantFuture)) < 0.001)
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

    @Test
    func fallsIntoTheDayItWasRecordedOn() throws {
        // Sunday 23:00 in New York is already Monday in Berlin.
        let session = try store.session(13, hour: 23, zone: "America/New_York")
        let sunday = try #require(calendar.dateInterval(of: .day, for: calendar.date(13)))
        let monday = try #require(calendar.dateInterval(of: .day, for: calendar.date(14)))

        #expect(session.falls(into: sunday, in: calendar))
        #expect(!session.falls(into: monday, in: calendar))
    }

    @Test
    func periodIsTheOneItWasRecordedIn() throws {
        // Sunday 23:00 in New York is already Monday in Berlin, the start of the next week.
        let session = try store.session(13, hour: 23, zone: "America/New_York")

        #expect(try session.period(of: .weekOfYear, in: calendar) == calendar.dateInterval(of: .weekOfYear, for: calendar.date(13)))
    }

    @Test(arguments: ["Europe/Berlin", "America/New_York"])
    func sessionStartingAtMidnightFallsIntoTheNewDay(zone: String) throws {
        let session = try store.session(14, hour: 0, zone: zone)
        session.started = session.started.addingTimeInterval(0.25)
        let sunday = try #require(calendar.dateInterval(of: .day, for: calendar.date(13)))
        let monday = try #require(calendar.dateInterval(of: .day, for: calendar.date(14)))

        #expect(!session.falls(into: sunday, in: calendar))
        #expect(session.falls(into: monday, in: calendar))
    }

    @Test
    func sessionEndingTheDayFallsIntoIt() throws {
        let session = try store.session(13, hour: 23, minute: 59, zone: "America/New_York")
        session.started = session.started.addingTimeInterval(59.75)
        let sunday = try #require(calendar.dateInterval(of: .day, for: calendar.date(13)))

        #expect(session.falls(into: sunday, in: calendar))
    }

    @Test
    func startMinuteIsTheClockTimeItWasRecordedAt() throws {
        // 08:30 in New York is 14:30 in Berlin, but the user saw 08:30.
        let session = try store.session(14, hour: 8, minute: 30, zone: "America/New_York")

        #expect(session.startMinute(in: calendar) == 8 * 60 + 30)
    }

    @Test
    func unknownTimeZoneFallsBackToTheCurrentOne() throws {
        let session = try store.session(14)
        session.timeZoneIdentifier = "Nowhere/Invalid"

        #expect(session.localCalendar(from: calendar).timeZone == .current)
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

    /// Every session in the store, whichever workout it belongs to: the overall statistics are read over all
    /// of them.
    var sessions: [Session] {
        (try? store.context.fetch(FetchDescriptor<Session>())) ?? []
    }

    func statistics(at now: Date, in interval: DateInterval = .allTime, calendar: Calendar? = nil) -> OverallStatistics {
        OverallStatistics(sessions: sessions, interval: interval, now: now, calendar: calendar ?? self.calendar)
    }

    func month(_ month: Int) throws -> DateInterval {
        try #require(calendar.dateInterval(of: .month, for: calendar.date(10, month: month)))
    }

    @Test
    func withoutSessionsThereIsNoStreak() throws {
        let statistics = try statistics(at: calendar.date(16))

        #expect(statistics.weekStreak.value == 0)
        #expect(statistics.longestWeekStreak.value == 0)
        #expect(statistics.lastSession.value == nil)
    }

    @Test
    func unfinishedWeekDoesNotBreakTheStreak() throws {
        // Weeks of Aug 24, Aug 31 and Sep 7. Nothing yet in the week of Sep 14.
        try store.session(25, month: 8)
        try store.session(1)
        try store.session(9)

        #expect(try statistics(at: calendar.date(16)).weekStreak.value == 3)

        try store.session(15)

        #expect(try statistics(at: calendar.date(16)).weekStreak.value == 4)
    }

    @Test
    func emptyWeekBreaksTheStreak() throws {
        try store.session(1)
        try store.session(3)

        #expect(try statistics(at: calendar.date(16)).weekStreak.value == 0)
    }

    @Test
    func severalSessionsInOneWeekCountOnce() throws {
        for day in [7, 8, 9, 14] {
            try store.session(day)
        }

        #expect(try statistics(at: calendar.date(16)).weekStreak.value == 2)
    }

    @Test
    func runningSessionDoesNotCount() throws {
        try store.session(9)
        let running = try store.startSession()
        running.started = try calendar.date(15, hour: 8)

        #expect(try statistics(at: calendar.date(16)).weekStreak.value == 1)
    }

    @Test(arguments: [(2, 2), (1, 1)])
    func weeksStartOnTheCalendarsFirstWeekday(firstWeekday: Int, streak: Int) throws {
        // Sunday Sep 6 and Saturday Sep 12 are in different weeks when weeks start on Monday,
        // and in the same week when they start on Sunday.
        try store.session(6)
        try store.session(12)

        let calendar = Calendar.berlin(firstWeekday: firstWeekday)

        #expect(try statistics(at: calendar.date(13), calendar: calendar).weekStreak.value == streak)
    }

    @Test
    func streakSurvivesDaylightSavingTimeChanges() throws {
        // Daylight saving time ends on Sunday, Oct 25.
        try store.session(20, month: 10)
        try store.session(25, month: 10, hour: 22)
        try store.session(27, month: 10)
        try store.session(3, month: 11)

        #expect(try statistics(at: calendar.date(4, month: 11)).weekStreak.value == 3)
    }

    @Test
    func sessionsAreDatedByTheirRecordedTimeZone() throws {
        // Sunday 23:00 in New York is already Monday in Berlin, but it belongs to the week it was recorded in.
        try store.session(13, hour: 23, zone: "America/New_York")
        try store.session(7)

        #expect(try statistics(at: calendar.date(16)).weekStreak.value == 1)
    }

    @Test
    func recentSessionRecordedFurtherEastCounts() throws {
        // Trained in Berlin until 09:00, then flew to New York, where it's 05:00, two hours later.
        // By the clock it was recorded at, the session ended four hours from now.
        let session = try store.session(15)
        var newYork = calendar
        newYork.timeZone = try #require(TimeZone(identifier: "America/New_York"))

        let statistics = try statistics(at: newYork.date(15, hour: 5), calendar: newYork)

        #expect(statistics.weekStreak.value == 1)
        #expect(statistics.lastSession.value == session.ended)
    }

    @Test(arguments: [(8, 2), (9, 4)])
    func streakIsAsOfTheEndOfTheIntervalOrNowWhileItsOngoing(month: Int, streak: Int) throws {
        // Weeks of Aug 24, Aug 31, Sep 7 and Sep 14, viewed on Sep 16. September's end is still weeks away.
        for (day, month) in [(24, 8), (31, 8), (7, 9), (15, 9)] {
            try store.session(day, month: month)
        }

        #expect(try statistics(at: calendar.date(16), in: self.month(month)).weekStreak.value == streak)
    }

    @Test
    func pastIntervalKeepsTheStreakItEndedWith() throws {
        // Every week from Apr 27 to the week of Jun 1. The session on Jun 2 doesn't count for May.
        for (day, month) in [(28, 4), (5, 5), (12, 5), (19, 5), (26, 5), (2, 6)] {
            try store.session(day, month: month)
        }

        let may = try statistics(at: calendar.date(10, month: 6), in: month(5))

        #expect(may.weekStreak.value == 5)
        #expect(may.longestWeekStreak.value == 5)
        #expect(try statistics(at: calendar.date(10, month: 6)).weekStreak.value == 6)
    }

    @Test
    func pastIntervalIsAsSeenOnItsLastDay() throws {
        // Every week from Apr 27 to May 18. On Sunday, May 31, the week of May 25 isn't over yet.
        for (day, month) in [(28, 4), (5, 5), (12, 5), (19, 5)] {
            try store.session(day, month: month)
        }

        #expect(try statistics(at: calendar.date(10, month: 6), in: month(5)).weekStreak.value == 4)
    }

    @Test
    func longestStreakIsTheBestOneWhenTheIntervalEnded() throws {
        // Five weeks from Jul 6 to Aug 3, a gap, then four weeks from Sep 7 to Sep 28.
        for (day, month) in [(6, 7), (13, 7), (20, 7), (27, 7), (3, 8), (7, 9), (14, 9), (21, 9), (28, 9)] {
            try store.session(day, month: month)
        }

        let september = try statistics(at: calendar.date(16, month: 10), in: month(9))

        #expect(september.weekStreak.value == 4)
        #expect(september.longestWeekStreak.value == 5)
    }

    @Test
    func intervalInTheFutureHasNoStreak() throws {
        try store.session(7)
        try store.session(14)

        let october = try statistics(at: calendar.date(16), in: month(10))

        #expect(october.weekStreak.value == 0)
        #expect(october.longestWeekStreak.value == 0)
    }

    @Test
    func longestStreakCountsItsWeeksBeforeTheInterval() throws {
        // Weeks of Aug 24, Aug 31 and Sep 7, a gap, then the week of Sep 21.
        try store.session(24, month: 8)
        try store.session(1)
        try store.session(7)
        try store.session(22)

        let statistics = try statistics(at: calendar.date(23), in: month(9))

        #expect(statistics.longestWeekStreak.value == 3)
        #expect(statistics.weekStreak.value == 1)
    }

    @Test
    func longestStreakDoesNotCountWeeksAfterTheInterval() throws {
        // Weeks of Aug 24, Aug 31, Sep 7 and Sep 14.
        for (day, month) in [(24, 8), (31, 8), (7, 9), (14, 9)] {
            try store.session(day, month: month)
        }

        #expect(try statistics(at: calendar.date(16), in: month(8)).longestWeekStreak.value == 2)
    }

    /// A finished session of another workout, so that there is something to be favourite over.
    @discardableResult
    func session(of workout: Workout, day: Int, month: Int = 9, hour: Int = 8) throws -> Session {
        let session = try Session.start(workout, in: store.context)
        session.started = try calendar.date(day, month: month, hour: hour)
        session.ended = session.started.addingTimeInterval(3600)
        return session
    }

    /// A second workout of the store's own exercises.
    func workout(_ name: String) -> Workout {
        let workout = Workout(name: name, pictogram: .workout, schedule: .inactive, entries: [])
        store.context.insert(workout)
        return workout
    }

    @Test
    func completionsCountTheFinishedSessionsOfTheInterval() throws {
        try store.session(31, month: 8)
        try store.session(7)
        try store.session(8)
        _ = try store.startSession()

        #expect(try statistics(at: calendar.date(16)).completions.value == 3)
        #expect(try statistics(at: calendar.date(16), in: month(9)).completions.value == 2)
    }

    @Test
    func withoutSessionsThereIsNoFavouriteWorkout() throws {
        let statistics = try statistics(at: calendar.date(16))

        #expect(statistics.completions.value == 0)
        #expect(statistics.favoriteWorkout.value == nil)
    }

    @Test
    func favoriteWorkoutIsTheOneDoneMostOften() throws {
        let legs = workout("Leg Day")
        try store.session(7)
        try store.session(8)
        try session(of: legs, day: 9)

        let statistics = try statistics(at: calendar.date(16))

        #expect(statistics.favoriteWorkout.value === store.workout)
        #expect(statistics.favoriteWorkout.subtitle == store.workout.name)
    }

    @Test
    func workoutsLevelOnCountGoToTheOneDoneLast() throws {
        let legs = workout("Leg Day")
        try store.session(7)
        try session(of: legs, day: 8)

        #expect(try statistics(at: calendar.date(16)).favoriteWorkout.value === legs)

        try store.session(9)
        try session(of: legs, day: 10)
        try store.session(11)

        // Three each now, and the full body one was the last of them.
        #expect(try statistics(at: calendar.date(16)).favoriteWorkout.value === store.workout)
    }

    @Test
    func favoriteWorkoutCountsOnlyTheIntervalsSessions() throws {
        let legs = workout("Leg Day")
        try session(of: legs, day: 25, month: 8)
        try session(of: legs, day: 26, month: 8)
        try store.session(7)

        #expect(try statistics(at: calendar.date(16), in: month(9)).favoriteWorkout.value === store.workout)
        #expect(try statistics(at: calendar.date(16)).favoriteWorkout.value === legs)
    }

    @Test
    func withoutSessionsThereIsNoTypicalSessionEither() throws {
        let statistics = try statistics(at: calendar.date(16))

        #expect(statistics.typicalDuration.value == nil)
        #expect(statistics.typicalStartTime.value == nil)
    }

    @Test
    func typicalSessionIsTheMedianLengthAndARecordedStartTime() throws {
        for (day, hour, minutes) in [(7, 7, 30), (8, 8, 60), (9, 19, 120)] {
            try store.session(day, hour: hour, minutes: minutes)
        }

        let statistics = try statistics(at: calendar.date(16))

        // The middle of 30, 60 and 120 minutes, started at the recorded time closest to all the others.
        #expect(statistics.typicalDuration.value == .seconds(3600))
        #expect(statistics.typicalStartTime.value == DateComponents(hour: 8, minute: 0))
    }

    @Test
    func typicalSessionCountsOnlyTheIntervalsSessions() throws {
        try store.session(31, month: 8, hour: 7, minutes: 30)
        try store.session(7, hour: 19, minutes: 90)

        let statistics = try statistics(at: calendar.date(16), in: month(9))

        #expect(statistics.typicalDuration.value == .seconds(90 * 60))
        #expect(statistics.typicalStartTime.value == DateComponents(hour: 19, minute: 0))
    }

    @Test
    func withoutSessionsThereAreNoSessionsPerWeek() throws {
        #expect(try statistics(at: calendar.date(16)).sessionsPerWeek.value == nil)
    }

    @Test
    func sessionsPerWeekCountFromTheFirstSessionToToday() throws {
        // Four sessions over the two weeks from Sep 1 through Sep 14.
        for day in [1, 3, 8, 10] {
            try store.session(day)
        }

        #expect(try statistics(at: calendar.date(14)).sessionsPerWeek.value == 2)
    }

    @Test
    func sessionsPerWeekCoverAtLeastAWeek() throws {
        try store.session(15)

        #expect(try statistics(at: calendar.date(16)).sessionsPerWeek.value == 1)
    }

    @Test
    func sessionsPerWeekCountTheDaysOfTheIntervalSinceTheFirstSession() throws {
        // September started before Sep 8 and is ongoing, so it covers the two weeks from Sep 8 through Sep 21.
        try store.session(8)
        try store.session(10)

        #expect(try statistics(at: calendar.date(21), in: month(9)).sessionsPerWeek.value == 1)
    }

    @Test
    func pastIntervalCountsItsWholeLengthForSessionsPerWeek() throws {
        // August has 31 days. The sessions in July and September only mark when training began and don't count.
        for (day, month) in [(20, 7), (3, 8), (17, 8), (7, 9)] {
            try store.session(day, month: month)
        }

        let rate = try #require(try statistics(at: calendar.date(16), in: month(8)).sessionsPerWeek.value)

        #expect(abs(rate - 2 / (31.0 / 7)) < 1e-9)
    }

    @Test
    func intervalInTheFutureHasNoSessionsPerWeek() throws {
        try store.session(7)

        #expect(try statistics(at: calendar.date(16), in: month(10)).sessionsPerWeek.value == nil)
    }

    @Test
    func intervalIsHalfOpen() throws {
        // Starts exactly at midnight on Oct 1, so it belongs to October only.
        try store.session(1, month: 10, hour: 0)

        let now = try calendar.date(16, month: 10)

        #expect(try statistics(at: now, in: month(9)).lastSession.value == nil)
        #expect(try statistics(at: now, in: month(10)).lastSession.value != nil)
    }

    @Test
    func sessionBelongsToTheIntervalItStartedIn() throws {
        // Starts on Sep 30 at 23:30 and ends in October.
        try store.session(30, hour: 23, minute: 30)

        let now = try calendar.date(16, month: 10)

        #expect(try statistics(at: now, in: month(9)).lastSession.value != nil)
        #expect(try statistics(at: now, in: month(10)).lastSession.value == nil)
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

    func statistics(in interval: DateInterval = .allTime) -> WorkoutStatistics {
        WorkoutStatistics(workout: store.workout, interval: interval, calendar: calendar)
    }

    @Test
    func workoutWithoutSessionsHasNoValues() {
        let statistics = statistics()

        #expect(statistics.lastCompleted.value == nil)
        #expect(statistics.completions.value == 0)
        #expect(statistics.completionRate.value == nil)
        #expect(statistics.typicalDuration.value == nil)
        #expect(statistics.typicalStartTime.value == nil)
        #expect(statistics.mostSkippedExercise.value == nil)
    }

    @Test
    func countsFinishedSessionsAndMostSkippedExercise() throws {
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

    @Test
    func completionRateCoversEveryExerciseOfFinishedSessions() throws {
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

    @Test
    func typicalDurationIsTheMedian() throws {
        for (day, minutes) in [(7, 30), (8, 60), (9, 120)] {
            try store.session(day, minutes: minutes)
        }

        #expect(statistics().typicalDuration.value == .seconds(3600))
    }

    @Test
    func typicalStartTimeIsARecordedStartTime() throws {
        for (day, hour, minute) in [(7, 7, 0), (8, 8, 15), (9, 19, 30)] {
            try store.session(day, hour: hour, minute: minute)
        }

        #expect(statistics().typicalStartTime.value == DateComponents(hour: 8, minute: 15))
    }

    @Test
    func typicalStartTimeIsNeverBetweenTwoStartTimes() throws {
        // An even count: the middle of 07:00 and 19:30 is 13:15, which was never trained at.
        try store.session(7, hour: 7)
        try store.session(8, hour: 19, minute: 30)

        #expect(statistics().typicalStartTime.value == DateComponents(hour: 7, minute: 0))
    }

    @Test
    func typicalStartTimeWrapsAroundMidnight() throws {
        // 23:30 and 00:30 are an hour apart on the clock, so neither midday nor anything between them.
        try store.session(7, hour: 23, minute: 30)
        try store.session(9, hour: 0, minute: 30)
        try store.session(10, hour: 0, minute: 30)

        #expect(statistics().typicalStartTime.value == DateComponents(hour: 0, minute: 30))
    }

    @Test
    func typicalStartTimeUsesTheRecordedTimeZone() throws {
        // 08:00 in New York is 14:00 in Berlin, but the user saw 08:00.
        try store.session(7, hour: 8)
        try store.session(8, hour: 8, zone: "America/New_York")

        #expect(statistics().typicalStartTime.value == DateComponents(hour: 8, minute: 0))
    }

    @Test
    func lastCompletedShowsTheDayItStartedOnItsClock() throws {
        // Runs from 23:30 on May 28 to 00:30 on May 29 in New York. It started at 05:30 on May 29 in Berlin.
        try store.session(28, month: 5, hour: 23, minute: 30, zone: "America/New_York")
        let subtitle = statistics().lastCompleted.subtitle

        #expect(try subtitle == Metric<Date>.lastCompleted(calendar.date(28, month: 5), in: nil, calendar: calendar).subtitle)
        #expect(try subtitle != Metric<Date>.lastCompleted(calendar.date(29, month: 5), in: nil, calendar: calendar).subtitle)
    }

    @Test
    func onlySessionsWithinTheIntervalCount() throws {
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

    func statistics(in interval: DateInterval = .allTime) -> ExerciseStatistics {
        ExerciseStatistics(exercise: squat, interval: interval, calendar: calendar)
    }

    @Test
    func exerciseWithoutSessionsHasNoValues() {
        let statistics = statistics()

        #expect(statistics.lastCompleted.value == nil)
        #expect(statistics.completionRate.value == nil)
        #expect(statistics.personalBest.value == nil)
        #expect(statistics.completions.value == 0)
        #expect(statistics.completions.subtitle == "0")
    }

    @Test
    func onlyFinishedSessionsCount() throws {
        try store.session(7) { $0.completeAndAdvance() }
        let running = try store.startSession()
        running.skipAndAdvance()

        let statistics = statistics()

        #expect(statistics.completions.value == 1)
        #expect(statistics.completionRate.value == 1)
        #expect(statistics.lastCompleted.value != nil)
    }

    @Test
    func skippedEntriesLowerTheCompletionRate() throws {
        try store.session(7) { $0.completeAndAdvance() }
        try store.session(8) { $0.skipAndAdvance() }

        let statistics = statistics()

        #expect(statistics.completions.value == 1)
        #expect(statistics.completionRate.value == 0.5)
    }

    @Test
    func onlySessionsWithinTheIntervalCount() throws {
        try store.session(31, month: 8) { $0.completeAndAdvance() }
        try store.session(7) { $0.skipAndAdvance() }

        let statistics = try statistics(in: #require(calendar.dateInterval(of: .month, for: calendar.date(10))))

        #expect(statistics.completions.value == 0)
        #expect(statistics.completionRate.value == 0)
        #expect(statistics.personalBest.value == nil)
    }

    @Test
    func personalBestIgnoresTargetsOfAnotherType() throws {
        try store.session(7) { $0.completeAndAdvance() }

        #expect(statistics().personalBest.value?.bodyweightTarget == .init(sets: 3, reps: 10))

        squat.type = .weight

        #expect(statistics().personalBest.value == nil)
    }
}

// MARK: - Session summary

@MainActor
struct SessionSummaryTests {
    let store: TestStore

    let calendar = Calendar.berlin()

    init() throws {
        self.store = try TestStore()
    }

    func summary(_ session: Session) -> SessionSummary {
        SessionSummary(session: session, calendar: calendar)
    }

    /// Completes the session's exercises in order, at the given offsets in minutes from when it started.
    func resolve(_ session: Session, after offsets: [Int]) {
        for (entry, offset) in zip(session.entries.sorted(), offsets) {
            entry.status = .completed(at: session.started.addingTimeInterval(TimeInterval(offset * 60)))
        }
    }

    @Test
    func unfinishedSessionHasNoDurationOrEndTime() throws {
        let unfinished = try summary(store.startSession())

        #expect(unfinished.duration.value == nil)
        #expect(unfinished.endTime.value == nil)
        #expect(unfinished.medianExerciseDuration.value == nil)
        #expect(unfinished.skipRate.value == 0)
    }

    @Test
    func durationIsTheTimeFromStartToFinish() throws {
        #expect(try summary(store.session(7, minutes: 45)).duration.value == .seconds(45 * 60))
    }

    /// Gives the session's exercises weight targets, in workout order, and completes them.
    func load(_ session: Session, kilograms: [Double], sets: Int = 3, reps: Int = 10) {
        for (entry, weight) in zip(session.entries.sorted(), kilograms) {
            entry.target = .weight(target: .init(weight: Quantity(weight, in: .kilograms), sets: sets, reps: reps))
            entry.status = .completed(at: session.started)
        }
    }

    @Test
    func completedExercisesCountsOnlyTheCompletedOnes() throws {
        let session = try store.session(7) { session in
            session.completeAndAdvance()
            session.skipAndAdvance()
        }

        // One completed, one skipped, one left pending.
        #expect(summary(session).completedExercises.value == 1)
    }

    @Test
    func totalVolumeIsLoadTimesSetsTimesReps() throws {
        let session = try store.session(7)
        load(session, kilograms: [100, 50], sets: 3, reps: 10)

        // 100 x 3 x 10 plus 50 x 3 x 10, with the third exercise left pending.
        #expect(summary(session).totalVolume.value?.base == 4500)
    }

    @Test
    func totalVolumeLeavesOutSkippedExercises() throws {
        let session = try store.session(7)
        load(session, kilograms: [100, 50], sets: 1, reps: 1)
        let skipped = try #require(session.entries.sorted().last)
        skipped.target = .weight(target: .init(weight: Quantity(999, in: .kilograms), sets: 1, reps: 1))
        skipped.status = .skipped(at: session.started)

        #expect(summary(session).totalVolume.value?.base == 150)
    }

    @Test
    func sessionWithoutWeightedExercisesHasNoVolume() throws {
        let session = try store.session(7) { session in
            session.completeAndAdvance()
            session.completeAndAdvance()
            session.completeAndAdvance()
        }

        // The store's exercises are all bodyweight, which carries no load, so there is nothing to total.
        #expect(summary(session).completedExercises.value == 3)
        #expect(summary(session).totalVolume.value == nil)
        #expect(summary(session).totalVolume.subtitle == nil)
    }

    @Test
    func totalVolumeReadsInTheUnitTheLoadWasRecordedIn() throws {
        let session = try store.session(7)
        let entry = try #require(session.entries.sorted().first)
        entry.target = .weight(target: .init(weight: Quantity(100, in: .pounds), sets: 2, reps: 5))
        entry.status = .completed(at: session.started)

        let volume = try #require(summary(session).totalVolume.value)

        #expect(volume.unit == .pounds)
        #expect(volume.value == 1000)
        #expect(summary(session).totalVolume.subtitle == Quantity(1000, in: .pounds).formatted)
    }

    @Test
    func skipRateCountsEveryExerciseOfTheSession() throws {
        let session = try store.session(7) { session in
            session.skipAndAdvance()
            session.completeAndAdvance()
        }

        // One skipped and one completed of three, with the last one left pending.
        #expect(summary(session).skipRate.value == 1.0 / 3.0)
    }

    @Test
    func exerciseDurationRunsFromTheResolutionBeforeIt() throws {
        let session = try store.session(7, minutes: 90)
        resolve(session, after: [10, 20, 60])

        let durations: [TimeInterval] = session.orderedEntries.compactMap(\.duration)

        // 10, 10 and 40 minutes: the first exercise counts from the start of the session, the others from
        // the one resolved before them.
        #expect(durations == [600, 600, 2400])
    }

    @Test
    func pendingExerciseHasNoDuration() throws {
        let session = try store.session(7, minutes: 90)
        resolve(session, after: [10])

        #expect(try #require(session.orderedEntries.last).duration == nil)
    }

    @Test
    func exerciseDurationRunsFromTheLastResolutionAndNotTheEntryBeforeIt() throws {
        let session = try store.session(7, minutes: 90)
        resolve(session, after: [60, 10, 20])
        let durations: [TimeInterval] = session.entries.sorted().compactMap(\.duration)

        // In workout order: the first was resolved last, so it took the 40 minutes since the one before it.
        #expect(durations == [2400, 600, 600])
    }

    @Test
    func medianExerciseDurationIsTheMiddleOfTheExerciseDurations() throws {
        let session = try store.session(7, minutes: 90)
        resolve(session, after: [10, 20, 60])

        // 10, 10 and 40 minutes, so the middle one is what a typical exercise took.
        #expect(summary(session).medianExerciseDuration.value == .seconds(10 * 60))
    }

    @Test
    func medianExerciseDurationIsNotSkewedByOneLongGap() throws {
        let early = try store.session(7, minutes: 90)
        let late = try store.session(8, minutes: 90)
        resolve(early, after: [0, 10, 20])
        resolve(late, after: [40, 50, 60])

        // The late one spent 40 minutes before its first exercise, which a mean would have spread over all three.
        #expect(summary(early).medianExerciseDuration.value == .seconds(10 * 60))
        #expect(summary(late).medianExerciseDuration.value == summary(early).medianExerciseDuration.value)
    }

    @Test
    func medianExerciseDurationSplitsAnEvenCount() throws {
        let session = try store.session(7, minutes: 90)
        resolve(session, after: [10, 30])

        // 10 and 20 minutes, so it lands between them.
        #expect(summary(session).medianExerciseDuration.value == .seconds(15 * 60))
    }

    @Test
    func medianExerciseDurationNeedsAResolvedExercise() throws {
        let session = try store.session(7, minutes: 90)

        #expect(summary(session).medianExerciseDuration.value == nil)

        resolve(session, after: [15])

        // A single resolved exercise still counts, from the start of the session.
        #expect(summary(session).medianExerciseDuration.value == .seconds(15 * 60))
    }

    @Test
    func shortExercisesAreReadInSecondsAndNotAsNoTimeAtAll() throws {
        let session = try store.session(7, minutes: 90)
        resolve(session, after: [0, 0, 0])
        let quick = try #require(session.entries.sorted().first)
        quick.status = .completed(at: session.started.addingTimeInterval(40))

        #expect(quick.duration == 40)
        #expect(Duration.seconds(40).formatted(.exerciseDuration) == Duration.seconds(40).formatted(.units(allowed: [.seconds], width: .abbreviated)))
        #expect(Duration.seconds(150).formatted(.exerciseDuration) == Duration.seconds(150).formatted(.units(allowed: [.minutes], width: .abbreviated)))
        #expect(summary(session).medianExerciseDuration.subtitle == Duration.seconds(0).formatted(.exerciseDuration))
    }

    @Test
    func endTimeIsTheClockTimeItWasRecordedAt() throws {
        // 08:00 in New York is 14:00 in Berlin, but the user saw the session end at 09:00.
        let session = try store.session(7, hour: 8, minutes: 60, zone: "America/New_York")
        var newYork = calendar
        newYork.timeZone = try #require(TimeZone(identifier: "America/New_York"))
        let ended = try newYork.date(7, hour: 9)
        let inNewYork = Date.FormatStyle(date: .omitted, time: .shortened, calendar: newYork, timeZone: newYork.timeZone)
        let inBerlin = Date.FormatStyle(date: .omitted, time: .shortened, calendar: calendar, timeZone: calendar.timeZone)

        #expect(summary(session).endTime.value == ended)
        #expect(summary(session).endTime.subtitle == ended.formatted(inNewYork))
        #expect(summary(session).endTime.subtitle != ended.formatted(inBerlin))
    }
}

// MARK: - Session entry

@MainActor
struct SessionEntryComparisonTests {
    let store: TestStore

    let squat: Exercise

    init() throws {
        self.store = try TestStore()
        self.squat = try #require(store.workout.entries.sorted().first?.exercise)
    }

    /// The squat entry of a session completed on the given day, at the given number of reps.
    @discardableResult
    func squatSession(_ day: Int, reps: Int) throws -> SessionEntry {
        let session = try store.session(day)
        let entry = try #require(session.entries.sorted().first)
        entry.target = .bodyweight(target: .init(sets: 3, reps: reps))
        entry.status = .completed(at: session.started)
        return entry
    }

    @Test
    func firstTimeAnExerciseIsCompletedIsNotAPersonalBest() throws {
        // There is nothing on record to have beaten, and a first session of nothing but trophies marks nothing.
        #expect(try squatSession(7, reps: 10).isBest == false)
    }

    @Test
    func beatingEveryEarlierTimeIsAPersonalBest() throws {
        try squatSession(7, reps: 10)

        #expect(try squatSession(8, reps: 12).isBest)
    }

    @Test
    func matchingTheBestIsNotAPersonalBest() throws {
        try squatSession(7, reps: 12)

        #expect(try squatSession(8, reps: 12).isBest == false)
    }

    @Test
    func personalBestStandsEvenAfterALaterBetterOne() throws {
        try squatSession(7, reps: 8)
        let earlier = try squatSession(8, reps: 10)
        let later = try squatSession(9, reps: 12)

        // Both beat everything on record on the day they were done, which is what the trophy marks.
        #expect(earlier.isBest)
        #expect(later.isBest)
    }

    @Test
    func skippedExerciseIsNeverAPersonalBest() throws {
        let session = try store.session(7)
        let entry = try #require(session.entries.sorted().first)
        entry.target = .bodyweight(target: .init(sets: 3, reps: 20))
        entry.status = .skipped(at: session.started)

        #expect(entry.isBest == false)
    }

    @Test
    func exerciseDroppedFromTheWorkoutIsNoLongerAPersonalBest() throws {
        try squatSession(7, reps: 10)
        let entry = try squatSession(8, reps: 12)
        let slot = try #require(entry.workoutEntry)

        #expect(entry.isBest)

        store.context.delete(slot)
        // The `.nullify` rule only reaches the session entry once the deletion is processed.
        try store.context.save()

        // The slot took its history with it, so there is nothing left to say this beat anything.
        #expect(entry.workoutEntry == nil)
        #expect(entry.isBest == false)
    }

    @Test
    func runningSessionIsNeverAPersonalBest() throws {
        let running = try store.startSession()
        running.completeAndAdvance()

        #expect(try #require(running.entries.sorted().first).isBest == false)
    }

    @Test
    func previousIsTheLastComparableTime() throws {
        try squatSession(7, reps: 12)
        try squatSession(8, reps: 10)

        #expect(try squatSession(9, reps: 11).previous?.rank == 10)
    }

    @Test
    func previousBestIsTheHighestComparableTime() throws {
        try squatSession(7, reps: 12)
        try squatSession(8, reps: 10)

        #expect(try squatSession(9, reps: 11).previousBest?.rank == 12)
    }

    @Test
    func firstTimeHasNothingToCompareWith() throws {
        let entry = try squatSession(7, reps: 10)

        #expect(entry.previous == nil)
        #expect(entry.previousBest == nil)
    }

    @Test
    func skippedExerciseHasNothingToCompareWith() throws {
        try squatSession(7, reps: 10)
        let entry = try squatSession(8, reps: 12)
        entry.status = try .skipped(at: #require(entry.session).started)

        #expect(entry.previous == nil)
        #expect(entry.previousBest == nil)
    }

    @Test
    func differenceInRepsReadsAsACount() {
        let target = ExerciseTarget.bodyweight(target: .init(sets: 3, reps: 12))

        #expect(target.formattedRank(2) == String(localized: .exerciseTargetRepsTitle(2)))
    }

    @Test
    func differenceReadsInTheUnitItWasRecordedIn() throws {
        squat.type = .weight
        let earlier = try store.session(7)
        let later = try store.session(8)

        for (session, kilograms) in [(earlier, 100.0), (later, 102.5)] {
            let entry = try #require(session.entries.sorted().first)
            entry.target = .weight(target: .init(weight: Quantity(kilograms, in: .kilograms), sets: 3, reps: 5))
            entry.status = .completed(at: session.started)
        }

        let entry = try #require(later.entries.sorted().first)
        let previous = try #require(entry.previous)

        #expect(entry.target.formattedRank(entry.target.rank - previous.rank) == Quantity(2.5, in: .kilograms).formatted)
    }

    @Test
    func targetsOfAnotherTypeAreNotComparable() throws {
        try squatSession(7, reps: 10)
        let entry = try squatSession(8, reps: 12)

        // The exercise is a weight exercise now, so neither bodyweight target can be ranked against it.
        squat.type = .weight

        #expect(entry.previous == nil)
        #expect(entry.isBest == false)
    }
}

// MARK: - Session entry scope

@MainActor
struct SessionEntryScopeTests {
    let store: TestStore

    let squat: Exercise

    init() throws {
        self.store = try TestStore()
        self.squat = try #require(store.workout.entries.sorted().first?.exercise)
        squat.type = .weight
    }

    /// Completes the given slot of a session of `workout` on the given day, at the given weight.
    @discardableResult
    func lift(_ slot: WorkoutEntry, of workout: Workout, day: Int, kilograms: Double) throws -> SessionEntry {
        let session = try Session.start(workout, in: store.context)
        let entry = try #require(session.entries.first { $0.workoutEntry === slot })
        entry.target = .weight(target: .init(weight: Quantity(kilograms, in: .kilograms), sets: 3, reps: 5))
        entry.status = try .completed(at: Calendar.berlin().date(day))
        session.started = try Calendar.berlin().date(day)
        session.ended = session.started
        return entry
    }

    @Test
    func trendIgnoresTheSameExerciseInAnotherWorkout() throws {
        // A warmup at 40 kg in one workout, the real thing at 100 then 102.5 kg in another.
        let warmups = Workout(name: "Warmup", pictogram: .workout, schedule: .inactive, entries: [])
        store.context.insert(warmups)
        warmups.append(exercise: squat, target: .weight(target: .init(weight: Quantity(40, in: .kilograms), sets: 1, reps: 5)))

        let warmupSlot = try #require(warmups.entries.sorted().first)
        let mainSlot = try #require(store.workout.entries.sorted().first)

        try lift(mainSlot, of: store.workout, day: 7, kilograms: 100)
        try lift(warmupSlot, of: warmups, day: 8, kilograms: 40)
        let main = try lift(mainSlot, of: store.workout, day: 9, kilograms: 102.5)

        // Without slot scoping the previous time would be the warmup at 40 kg.
        #expect(try #require(main.previous).formattedRank == Quantity(100, in: .kilograms).formatted)
    }

    @Test
    func trendKeepsTheTwoSlotsOfOneWorkoutApart() throws {
        // The same exercise twice in one workout: a light opener and a heavy set.
        store.workout.append(exercise: squat, target: .weight(target: .init(weight: Quantity(60, in: .kilograms), sets: 1, reps: 5)))

        let slots = store.workout.entries.filter { $0.exercise === squat }.sorted()
        let heavy = try #require(slots.first)
        let light = try #require(slots.last)

        #expect(slots.count == 2)

        try lift(heavy, of: store.workout, day: 7, kilograms: 100)
        try lift(light, of: store.workout, day: 7, kilograms: 60)
        let laterHeavy = try lift(heavy, of: store.workout, day: 8, kilograms: 105)

        #expect(try #require(laterHeavy.previous).formattedRank == Quantity(100, in: .kilograms).formatted)
    }

    @Test
    func personalBestIsScopedToTheSlotToo() throws {
        let warmups = Workout(name: "Warmup", pictogram: .workout, schedule: .inactive, entries: [])
        store.context.insert(warmups)
        warmups.append(exercise: squat, target: .weight(target: .init(weight: Quantity(40, in: .kilograms), sets: 1, reps: 5)))

        let warmupSlot = try #require(warmups.entries.sorted().first)
        let mainSlot = try #require(store.workout.entries.sorted().first)

        try lift(mainSlot, of: store.workout, day: 7, kilograms: 100)
        let first = try lift(warmupSlot, of: warmups, day: 8, kilograms: 40)

        // The slot has no history of its own yet, so there is nothing for the warmup to have beaten.
        #expect(first.previous == nil)
        #expect(first.isBest == false)

        let heavier = try lift(warmupSlot, of: warmups, day: 9, kilograms: 45)

        // The trophy is per slot, so beating the warmup's own 40 kg earns one despite the 100 kg on record.
        #expect(heavier.isBest)

        let lighter = try lift(warmupSlot, of: warmups, day: 10, kilograms: 35)

        // The slot's own history still applies, so a lighter one afterwards doesn't.
        #expect(lighter.isBest == false)
        #expect(try #require(lighter.previous).formattedRank == Quantity(45, in: .kilograms).formatted)
        #expect(try #require(lighter.previousBest).formattedRank == Quantity(45, in: .kilograms).formatted)
    }
}

// MARK: - Current highest target

@MainActor
struct ExerciseCurrentHighestTargetTests {
    let store: TestStore

    let squat: Exercise

    init() throws {
        self.store = try TestStore()
        self.squat = try #require(store.workout.entries.sorted().first?.exercise)
    }

    /// A second workout holding the squat at the given number of reps.
    @discardableResult
    func workout(_ name: String, reps: Int) throws -> Workout {
        let workout = Workout(name: name, pictogram: .workout, schedule: .inactive, entries: [])
        store.context.insert(workout)
        workout.append(exercise: squat, target: .bodyweight(target: .init(sets: 3, reps: reps)))
        return workout
    }

    @Test
    func anExerciseInNoWorkoutHasNothingToGoOn() {
        let rows = Exercise(name: "Rows", type: .bodyweight, categories: [])
        store.context.insert(rows)

        #expect(rows.currentHighestTarget == nil)
    }

    @Test
    func theHighestRankedSlotWinsAcrossWorkouts() throws {
        try workout("Heavy", reps: 15)
        try workout("Light", reps: 5)

        // The squat sits at 10 reps in the store's own workout, so 15 is the one to beat.
        #expect(squat.currentHighestTarget?.bodyweightTarget == .init(sets: 3, reps: 15))
    }

    @Test
    func aSlotNeverPerformedStillCounts() throws {
        try workout("Planned", reps: 15)

        // No session has ever touched it, but it is what the exercise is programmed at.
        #expect(squat.currentHighestTarget?.bodyweightTarget == .init(sets: 3, reps: 15))
    }

    @Test
    func finishingASessionPutsWhatWasDoneOnOffer() throws {
        let session = try store.startSession()
        let entry = try #require(session.entries.first { $0.exercise === squat })
        entry.target = .bodyweight(target: .init(sets: 3, reps: 20))
        entry.status = .completed(at: .now)
        session.finish()

        // `finish` writes targets back to their slots, so the workout now holds what was actually done.
        #expect(squat.currentHighestTarget?.bodyweightTarget == .init(sets: 3, reps: 20))
    }

    @Test
    func deletingAWorkoutTakesItsNumbersWithIt() throws {
        let heavy = try workout("Heavy", reps: 15)

        #expect(squat.currentHighestTarget?.bodyweightTarget == .init(sets: 3, reps: 15))

        store.context.delete(heavy)
        // The `.cascade` rule only reaches the workout's entries once the deletion is processed.
        try store.context.save()

        // Giving the heavy workout up drops its numbers, which is what keeps stale weights from coming back.
        #expect(squat.currentHighestTarget?.bodyweightTarget == .init(sets: 3, reps: 10))
    }

    @Test
    func targetsOfAnotherTypeAreIgnored() throws {
        try workout("Heavy", reps: 15)
        squat.type = .weight

        // Every slot still holds reps, which say nothing about how heavy the exercise is now measured in.
        #expect(squat.currentHighestTarget == nil)
    }
}

// MARK: - Progression

@MainActor
struct ProgressionTests {
    let store: TestStore

    let squat: Exercise

    let calendar = Calendar.berlin()

    init() throws {
        self.store = try TestStore()
        self.squat = try #require(store.workout.entries.sorted().first?.exercise)
    }

    func progression(in interval: DateInterval = .allTime) -> Progression<ExerciseTarget> {
        ExerciseStatistics(exercise: squat, interval: interval, calendar: calendar).progression
    }

    /// A session with its squat completed at the given number of reps.
    @discardableResult
    func squatSession(_ day: Int, month: Int = 9, hour: Int = 8, reps: Int) throws -> Session {
        let session = try store.session(day, month: month, hour: hour)
        let entry = try #require(session.entries.sorted().first)
        entry.target = .bodyweight(target: .init(sets: 3, reps: reps))
        entry.status = .completed(at: session.started)
        return session
    }

    @Test
    func exerciseWithoutCompletionsHasNoPoints() {
        #expect(progression().points.isEmpty)
    }

    @Test
    func everyDayItWasCompletedOnIsAPoint() throws {
        try squatSession(7, reps: 10)
        try squatSession(9, reps: 12)

        let points = progression().points

        #expect(points.map(\.rank) == [10, 12])
        #expect(try points.map(\.date) == [calendar.date(7, hour: 0), calendar.date(9, hour: 0)])
    }

    @Test
    func pointsAreOldestFirst() throws {
        try squatSession(9, reps: 12)
        try squatSession(7, reps: 10)

        #expect(progression().points.map(\.rank) == [10, 12])
    }

    @Test
    func aDayIsOnePointAtItsBest() throws {
        // A warmup in the morning and the real thing in the evening: the day is worth what it got to.
        try squatSession(7, hour: 8, reps: 5)
        try squatSession(7, hour: 18, reps: 12)

        #expect(progression().points.map(\.rank) == [12])
    }

    @Test
    func skippedAndPendingExercisesAreNoPoints() throws {
        try store.session(7) { $0.skipAndAdvance() }
        try store.session(8)

        #expect(progression().points.isEmpty)
    }

    @Test
    func runningSessionsAreNoPoints() throws {
        let running = try store.startSession()
        running.completeAndAdvance()

        #expect(progression().points.isEmpty)
    }

    @Test
    func targetsOfAnotherTypeAreLeftOut() throws {
        try squatSession(7, reps: 10)

        #expect(progression().points.count == 1)

        // Reps say nothing about how heavy the exercise is now measured in.
        squat.type = .weight

        #expect(progression().points.isEmpty)
    }

    @Test
    func onlySessionsWithinTheIntervalCount() throws {
        try squatSession(31, month: 8, reps: 10)
        try squatSession(7, reps: 12)

        let september = try #require(calendar.dateInterval(of: .month, for: calendar.date(10)))

        #expect(progression(in: september).points.map(\.rank) == [12])
    }

    @Test
    func pointsAreDatedByTheClockTheyWereRecordedOn() throws {
        // Sunday 23:00 in New York is already Monday in Berlin, but the user trained on Sunday.
        let session = try store.session(13, hour: 23, zone: "America/New_York")
        let entry = try #require(session.entries.sorted().first)
        entry.status = .completed(at: session.started)

        #expect(try progression().points.map(\.date) == [calendar.date(13, hour: 0)])
    }

    @Test
    func labelsReadInTheUnitTheTargetsWereRecordedIn() throws {
        squat.type = .weight
        let session = try store.session(7)
        let entry = try #require(session.entries.sorted().first)
        entry.target = .weight(target: .init(weight: Quantity(100, in: .pounds), sets: 3, reps: 5))
        entry.status = .completed(at: session.started)

        let progression = progression()

        // The rank is in kilograms, but the axis reads in the pounds it was logged in, unit and all.
        #expect(progression.points.map(\.rank) == [Quantity(100, in: .pounds).base])
        #expect(progression.label(for: Quantity(100, in: .pounds).base) == Quantity(100, in: .pounds).formatted)
    }

    @Test(arguments: [
        (ExerciseTarget.weight(target: .init(weight: Quantity(100, in: .kilograms), sets: 3, reps: 5)), "kg"),
        (ExerciseTarget.duration(target: .init(duration: Quantity(10, in: .minutes))), "min"),
        (ExerciseTarget.distance(target: .init(distance: Quantity(5, in: .kilometers))), "km"),
    ])
    func targetsAreMeasuredInWhatTheyWereRecordedIn(target: ExerciseTarget, symbol: String) {
        #expect(target.symbol == symbol)
        #expect(target.label(for: target.rank).hasSuffix(" \(symbol)"))
        #expect(target.formattedRank == target.label(for: target.rank))
    }

    @Test(arguments: [1, 12])
    func repsAreTheirOwnUnit(reps: Int) {
        let target = ExerciseTarget.bodyweight(target: .init(sets: 3, reps: reps))

        // The axis is headed with the unit whatever the count, while the rank itself reads as a count and
        // leaves the plural to the catalog.
        #expect(target.symbol == String(localized: .unitRepsSymbol))
        #expect(target.formattedRank == String(localized: .exerciseTargetRepsTitle(reps)))
    }

    @Test
    func repsAreTheUnitToReadRepsBackIn() throws {
        try squatSession(7, reps: 10)

        let expected = "\(10.0.formatted(.number.precision(.fractionLength(0)))) \(String(localized: .unitRepsSymbol))"

        #expect(progression().label(for: 10) == expected)
    }
}

// MARK: - Activity

@MainActor
struct HeatmapTests {
    let store: TestStore

    let calendar = Calendar.berlin()

    init() throws {
        self.store = try TestStore()
    }

    func heatmap(at now: Date, in interval: DateInterval = .allTime, calendar: Calendar? = nil) -> Heatmap {
        OverallStatistics(sessions: store.workout.sessions, interval: interval, now: now, calendar: calendar ?? self.calendar).activity
    }

    /// The twelve weeks a card asks for.
    func weeks(at now: Date, in interval: DateInterval = .allTime, calendar: Calendar? = nil) -> [Heatmap.Week] {
        heatmap(at: now, in: interval, calendar: calendar).weeks(12)
    }

    /// The cell the given day sits in, if the grid reaches back that far.
    func day(_ date: Date, in weeks: [Heatmap.Week]) -> Heatmap.Day? {
        weeks.flatMap(\.days).first { calendar.isDate($0.date, inSameDayAs: date) }
    }

    func activeDays(in weeks: [Heatmap.Week]) -> Int {
        weeks.flatMap(\.days).count { $0.value != nil }
    }

    @Test
    func gridIsAsManyWeeksOfSevenDaysAsAskedFor() throws {
        let heatmap = try heatmap(at: calendar.date(16))

        #expect(heatmap.weeks(12).count == 12)
        #expect(heatmap.weeks(4).count == 4)
        #expect(heatmap.weeks(12).allSatisfy { $0.days.count == 7 })
        #expect(activeDays(in: heatmap.weeks(12)) == 0)
    }

    @Test(arguments: [0, -1])
    func gridOfNoWeeksIsEmpty(count: Int) throws {
        #expect(try heatmap(at: calendar.date(16)).weeks(count).isEmpty)
    }

    @Test
    func gridEndsWithTheWeekItWasReadOn() throws {
        let now = try calendar.date(16)
        let weeks = weeks(at: now)

        #expect(try #require(weeks.last).start == #require(calendar.dateInterval(of: .weekOfYear, for: now)).start)
        #expect(day(now, in: weeks) != nil)
    }

    @Test
    func pastIntervalEndsWithTheWeekItDid() throws {
        try store.session(1, month: 10)
        let september = try #require(calendar.dateInterval(of: .month, for: calendar.date(10)))
        let weeks = try weeks(at: calendar.date(16, month: 10), in: september)

        // Read in October, September's grid still ends where September did.
        #expect(try #require(weeks.last).start == #require(calendar.dateInterval(of: .weekOfYear, for: calendar.date(30))).start)
        // October is in that last week, but not in September, so its session stays off the grid.
        #expect(try #require(day(calendar.date(1, month: 10), in: weeks)).value == nil)
    }

    @Test
    func intervalInTheFutureHasNoGrid() throws {
        let october = try #require(calendar.dateInterval(of: .month, for: calendar.date(10, month: 10)))

        // Read in September, October has no day to be read against yet, so there's nothing to lay out.
        #expect(try weeks(at: calendar.date(16), in: october).isEmpty)
    }

    @Test(arguments: [1, 2])
    func rowsStartOnTheCalendarsFirstWeekday(firstWeekday: Int) throws {
        let calendar = Calendar.berlin(firstWeekday: firstWeekday)
        let heatmap = try heatmap(at: calendar.date(16), calendar: calendar)

        #expect(heatmap.weeks(12).allSatisfy { calendar.component(.weekday, from: $0.start) == firstWeekday })
        #expect(heatmap.weeks(12).allSatisfy { $0.days.count == 7 })
        // The rows stand for the weekdays in the same order, which is what the card labels them with.
        #expect(heatmap.weekdays.count == 7)
        #expect(heatmap.weekdays.first == Schedule.Weekday(calendarNumber: firstWeekday))
    }

    @Test
    func aDayCountsEverythingDoneOnIt() throws {
        try store.session(7, hour: 8)
        try store.session(7, hour: 18)
        try store.session(8)

        let weeks = try weeks(at: calendar.date(16))

        #expect(try day(calendar.date(7), in: weeks)?.value == 2)
        #expect(try day(calendar.date(7), in: weeks)?.intensity == 1)
        #expect(try day(calendar.date(8), in: weeks)?.value == 1)
        #expect(try day(calendar.date(8), in: weeks)?.intensity == 0.5)
        #expect(try #require(day(calendar.date(9), in: weeks)).value == nil)
        #expect(activeDays(in: weeks) == 2)
    }

    @Test
    func daysAfterTheOneItWasReadOnAreStillAhead() throws {
        // Wednesday, so the rest of its week is still to come and stands for nothing.
        let weeks = try weeks(at: calendar.date(16))
        let last = try #require(weeks.last)

        #expect(try day(calendar.date(16), in: weeks)?.isAhead == false)
        #expect(try day(calendar.date(17), in: weeks)?.isAhead == true)
        #expect(last.days.count(where: \.isAhead) == 4)
        #expect(weeks.dropLast().allSatisfy { $0.days.allSatisfy { !$0.isAhead } })
    }

    @Test
    func daysAreShadedAgainstTheBusiestOneShown() throws {
        // Three sessions in February, long off the grid, and one on the grid in September.
        for hour in [8, 12, 18] {
            try store.session(1, month: 2, hour: hour)
        }
        try store.session(7)

        let weeks = try weeks(at: calendar.date(16))

        #expect(try day(calendar.date(7), in: weeks)?.intensity == 1)
    }

    @Test
    func daysAreTheOnesTheyWereRecordedOn() throws {
        // Sunday 23:00 in New York is already Monday in Berlin, but the user trained on Sunday.
        try store.session(13, hour: 23, zone: "America/New_York")

        let weeks = try weeks(at: calendar.date(16))

        #expect(try day(calendar.date(13), in: weeks)?.value == 1)
        #expect(try #require(day(calendar.date(14), in: weeks)).value == nil)
    }

    @Test
    func historyOlderThanTheGridIsNotOnIt() throws {
        // Twelve weeks up to the week of Sep 14 reach back to the week of Jun 29.
        try store.session(1, month: 2)
        try store.session(22, month: 6)
        try store.session(29, month: 6)

        let weeks = try weeks(at: calendar.date(16))

        #expect(try day(calendar.date(29, month: 6), in: weeks)?.value == 1)
        #expect(try day(calendar.date(22, month: 6), in: weeks) == nil)
        #expect(activeDays(in: weeks) == 1)
    }

    @Test
    func runningSessionsAreNotOnTheGrid() throws {
        let running = try store.startSession()
        running.started = try calendar.date(15)

        #expect(try activeDays(in: weeks(at: calendar.date(16))) == 0)
    }

    @Test
    func workoutCountsTheDaysItWasDoneOn() throws {
        try store.session(7, hour: 8)
        try store.session(7, hour: 18)

        let weeks = try WorkoutStatistics(workout: store.workout, now: calendar.date(16), calendar: calendar).activity.weeks(12)

        #expect(try day(calendar.date(7), in: weeks)?.value == 2)
        #expect(activeDays(in: weeks) == 1)
    }

    @Test
    func exerciseCountsTheDaysItWasCompletedOn() throws {
        // The squat is completed on the seventh and skipped on the eighth.
        try store.session(7) { session in
            session.completeAndAdvance()
            session.skipAndAdvance()
        }
        try store.session(8) { $0.skipAndAdvance() }

        let squat = try #require(store.workout.entries.sorted().first?.exercise)
        let weeks = try ExerciseStatistics(exercise: squat, now: calendar.date(16), calendar: calendar).activity.weeks(12)

        #expect(try day(calendar.date(7), in: weeks)?.value == 1)
        #expect(try #require(day(calendar.date(8), in: weeks)).value == nil)
        #expect(activeDays(in: weeks) == 1)
    }
}

// MARK: - Categories

@MainActor
struct DistributionTests {
    let store: TestStore

    let exercises: [Exercise]

    let calendar = Calendar.berlin()

    init() throws {
        self.store = try TestStore()
        self.exercises = store.workout.entries.sorted().compactMap(\.exercise)
    }

    /// What the workout plans to train.
    func planned() -> Distribution<ExerciseCategory> {
        WorkoutStatistics(workout: store.workout, calendar: calendar).categories
    }

    /// What was actually completed.
    func completed(in interval: DateInterval = .allTime) -> Distribution<ExerciseCategory> {
        OverallStatistics(sessions: store.workout.sessions, interval: interval, calendar: calendar).categories
    }

    /// Gives the workout's exercises a category each, in workout order.
    func categorize(_ categories: [Set<ExerciseCategory>]) {
        for (exercise, categories) in zip(exercises, categories) {
            exercise.categories = categories
        }
    }

    @Test
    func withoutCategoriesThereIsNothingToShow() {
        categorize([[], [], []])

        #expect(planned().shares.isEmpty)
    }

    @Test
    func anExerciseCountsInEachOfItsCategories() {
        categorize([[.legs, .back], [.chest], []])

        let distribution = planned()

        let third = 1.0 / 3.0

        // Three tallies over three categories, which tie and stay in the order they are declared in.
        #expect(distribution.shares.map(\.value) == [.legs, .chest, .back])
        #expect(distribution.shares.map(\.count) == [1, 1, 1])
        #expect(distribution.shares.map(\.fraction) == [third, third, third])
    }

    @Test
    func theMostTrainedCategoryComesFirst() {
        categorize([[.legs], [.legs, .chest], [.legs]])

        let distribution = planned()

        #expect(distribution.shares.map(\.value) == [.legs, .chest])
        #expect(distribution.shares.map(\.count) == [3, 1])
        #expect(distribution.shares.map(\.fraction) == [0.75, 0.25])
    }

    @Test
    func workoutCountsWhatItPlansAndNotWhatWasDone() throws {
        categorize([[.legs], [.chest], [.back]])
        try store.session(7) { $0.completeAndAdvance() }

        // Only the squat was done, but all three exercises are still on the plan.
        #expect(planned().shares.map(\.value) == [.legs, .chest, .back])
        #expect(planned().shares.allSatisfy { $0.count == 1 })
    }

    @Test
    func droppingAnExerciseTakesItsCategoriesWithIt() throws {
        categorize([[.legs], [.chest], [.back]])
        let bench = try #require(store.workout.entries.sorted().dropFirst().first)

        store.context.delete(bench)
        // The `.cascade` rule only reaches the workout's entries once the deletion is processed.
        try store.context.save()

        #expect(planned().shares.map(\.value) == [.legs, .back])
    }

    @Test
    func completedCountsOnlyTheExercisesThatWereDone() throws {
        categorize([[.legs], [.chest], [.back]])
        try store.session(7) { session in
            session.completeAndAdvance()
            session.skipAndAdvance()
        }

        // The bench press was skipped and the deadlift left pending, so neither was trained.
        #expect(completed().shares.map(\.value) == [.legs])
        #expect(completed().shares.map(\.fraction) == [1])
    }

    @Test
    func completedCountsEachTimeAnExerciseWasDone() throws {
        categorize([[.legs], [.legs, .chest], []])

        for day in [7, 8] {
            try store.session(day) { session in
                session.completeAndAdvance()
                session.completeAndAdvance()
            }
        }

        // Two squats and two bench presses, and the bench press trains two categories: six tallies in all.
        #expect(completed().shares.map(\.value) == [.legs, .chest])
        #expect(completed().shares.map(\.count) == [4, 2])
    }

    @Test
    func completedCountsOnlySessionsWithinTheInterval() throws {
        categorize([[.legs], [], []])
        try store.session(31, month: 8) { $0.completeAndAdvance() }

        let september = try #require(calendar.dateInterval(of: .month, for: calendar.date(10)))

        #expect(completed(in: september).shares.isEmpty)
        #expect(completed().shares.map(\.value) == [.legs])
    }

    @Test
    func runningSessionsAreNotCounted() throws {
        categorize([[.legs], [], []])
        let running = try store.startSession()
        running.completeAndAdvance()

        #expect(completed().shares.isEmpty)
    }
}
