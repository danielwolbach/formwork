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
        session.startDate = started
        session.endDate = started.addingTimeInterval(TimeInterval(duration * 60))
        session.timeZoneIdentifier = zone
        return session
    }
}

// MARK: - Formatting

extension StatisticKind {
    func reading(of value: Double, for subject: History.Subject = .all) -> Reading? {
        guard case let .metric(unit, _, _, _) = definition.value else {
            return nil
        }

        return Reading(value, as: unit, of: subject.exercise?.kind)
    }
}

struct StatisticFormattingTests {
    @Test
    func missingValueIsNotFormatted() {
        let allTime = History(.all, among: [], calendar: .berlin()).allTime

        #expect(allTime.lastCompletion == nil)
        #expect(StatisticKind.lastCompleted.reading(in: allTime) == nil)
        #expect(StatisticKind.lastCompleted.definition.title == String(localized: .statisticLastCompletedTitle))
        #expect(StatisticKind.lastCompleted.definition.pictogram == .date)
    }

    @Test
    func valueIsFormattedAsSubtitle() {
        #expect(StatisticKind.completions.reading(of: 3)?.formatted(.reading(units: .metric)) == "3")
    }

    @Test
    func weeklySessionsShowOneDecimal() {
        #expect(StatisticKind.weeklySessions.reading(of: 2)?.formatted(.reading(units: .metric)) == 2.0.formatted(.number.precision(.fractionLength(1))))
        #expect(StatisticKind.weeklySessions.reading(of: 1.46)?.formatted(.reading(units: .metric)) == 1.5.formatted(.number.precision(.fractionLength(1))))
    }

    @Test(arguments: [42.0, 2000, 3500])
    func typicalDurationUnderAnHourReadsLikeAnExercise(seconds: Double) {
        let exerciseStyle = Duration.UnitsFormatStyle.units(allowed: [.minutes, .seconds], width: .abbreviated, maximumUnitCount: 1)

        #expect(StatisticKind.typicalDuration.reading(of: seconds)?.formatted(.reading(units: .metric)) == Duration.seconds(seconds).formatted(exerciseStyle))
    }

    @Test(arguments: [(6120.0, 6120.0), (3590, 3600)])
    func typicalDurationFromAnHourReadsInHoursAndMinutes(seconds: Double, shown: Double) {
        // 59 min 50 sec rounds to the hour, so it reads as 1 hr rather than 60 min.
        #expect(StatisticKind.typicalDuration.reading(of: seconds)?.formatted(.reading(units: .metric)) == Duration.seconds(shown).formatted(.units(allowed: [.hours, .minutes], width: .abbreviated)))
    }

    @Test
    func dayWithinAWeekIsRelative() throws {
        let date = try #require(Calendar.berlin().date(byAdding: .day, value: -2, to: .now))
        var style = Date.RelativeFormatStyle(presentation: .named, calendar: .berlin(), capitalizationContext: .beginningOfSentence)
        style.allowedFields = [.day]

        #expect(Reading.day(date, calendar: .berlin()).formatted(.reading(units: .metric)) == date.formatted(style))
    }

    @Test
    func dayTodayIsTheDayAndNotTheHour() throws {
        // Two times on the same day, so neither may be shown as hours or minutes ago.
        let calendar = Calendar.berlin()
        let midnight = calendar.startOfDay(for: .now)
        let later = try #require(calendar.date(byAdding: .minute, value: 1, to: midnight))

        #expect(Reading.day(midnight, calendar: calendar).formatted(.reading(units: .metric)) == Reading.day(later, calendar: calendar).formatted(.reading(units: .metric)))
    }

    @Test
    func dayEarlierIsItsDateInTheCalendar() throws {
        // 23:30 on May 28 in New York is already May 29 in Berlin.
        let calendar = Calendar.berlin()
        var newYork = calendar
        newYork.timeZone = try #require(TimeZone(identifier: "America/New_York"))
        let date = try newYork.date(28, month: 5, year: 2025, hour: 23, minute: 30)
        let style = Date.FormatStyle(calendar: calendar, timeZone: calendar.timeZone).day().month().year()

        #expect(try Reading.day(date, calendar: newYork).formatted(.reading(units: .metric)) == calendar.date(28, month: 5, year: 2025).formatted(style))
    }

    @Test
    func timeIsFormattedInTheCalendarsTimeZone() throws {
        var tokyo = Calendar.berlin(), newYork = Calendar.berlin()
        tokyo.timeZone = try #require(TimeZone(identifier: "Asia/Tokyo"))
        newYork.timeZone = try #require(TimeZone(identifier: "America/New_York"))
        let time = DateComponents(hour: 8, minute: 15)

        let inTokyo = try Reading.time(#require(tokyo.date(from: time)), calendar: tokyo)
        let inNewYork = try Reading.time(#require(newYork.date(from: time)), calendar: newYork)

        #expect(inTokyo.formatted(.reading(units: .metric)) == inNewYork.formatted(.reading(units: .metric)))
    }

    @Test(arguments: [
        (ExerciseTarget.weight(kilograms: 100, reps: 10, sets: 3), "100 kg"),
        (ExerciseTarget.bodyweight(reps: 12, sets: 3), "12 reps"),
        (ExerciseTarget.duration(seconds: 10 * 60), Duration.seconds(600).formatted(.units(width: .abbreviated))),
        (ExerciseTarget.distance(meters: 5 * 1000), "5 km"),
    ])
    func personalBestShowsOnlyTheRank(target: ExerciseTarget, expected: String) {
        let exercise = Exercise(name: "Test", kind: target.exerciseKind, categories: [])

        #expect(StatisticKind.personalBest.reading(of: target.rank, for: .exercise(exercise))?.formatted(.reading(units: .metric)) == expected)
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
        session.startDate = session.startDate.addingTimeInterval(0.25)
        let sunday = try #require(calendar.dateInterval(of: .day, for: calendar.date(13)))
        let monday = try #require(calendar.dateInterval(of: .day, for: calendar.date(14)))

        #expect(!session.falls(into: sunday, in: calendar))
        #expect(session.falls(into: monday, in: calendar))
    }

    @Test
    func sessionEndingTheDayFallsIntoIt() throws {
        let session = try store.session(13, hour: 23, minute: 59, zone: "America/New_York")
        session.startDate = session.startDate.addingTimeInterval(59.75)
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

// MARK: - History

@MainActor
struct HistoryTests {
    let store: TestStore

    let calendar = Calendar.berlin()

    init() throws {
        self.store = try TestStore()
    }

    func history(at now: Date) -> History {
        History(.workout(store.workout), among: store.sessions, at: now, calendar: calendar)
    }

    @Test
    func recentIsTheLastFourWeeksTodayIncluded() throws {
        let recent = try history(at: calendar.date(16)).recent

        #expect(try recent.period == DateInterval(start: calendar.date(20, month: 8, hour: 0), end: calendar.date(17, hour: 0)))
    }

    @Test
    func baselineIsTheTwelveWeeksBeforeThem() throws {
        let history = try history(at: calendar.date(16))

        #expect(history.baseline.period.end == history.recent.period.start)
        #expect(calendar.dateComponents([.day], from: history.baseline.period.start, to: history.baseline.period.end).day == 84)
    }

    @Test
    func withoutSessionsNothingIsOnRecord() throws {
        let history = try history(at: calendar.date(16))

        #expect(history.allTime.interval.duration == 0)
        #expect(history.recent.interval.duration == 0)
    }

    @Test
    func subjectsKeepTheirOwnSessionsOfThePool() throws {
        let slot = try #require((store.workout.entries ?? []).sorted().first)
        let squat = try #require(slot.exercise)
        let legs = Workout(name: "Legs", pictogram: .workout, schedule: .inactive, entries: [])
        store.context.insert(legs)
        legs.append(exercise: squat, target: .bodyweight(reps: 10, sets: 3))

        let ours = try store.session(7)
        let theirs = try #require(legs.startSession())
        theirs.startDate = try calendar.date(8)
        theirs.endDate = theirs.startDate.addingTimeInterval(3600)

        func sessions(_ subject: History.Subject) throws -> Set<ObjectIdentifier> {
            try Set(History(subject, among: store.sessions, at: calendar.date(16), calendar: calendar).sessions.map(ObjectIdentifier.init))
        }

        #expect(try sessions(.all) == [ObjectIdentifier(ours), ObjectIdentifier(theirs)])
        #expect(try sessions(.workout(store.workout)) == [ObjectIdentifier(ours)])
        #expect(try sessions(.exercise(squat)) == [ObjectIdentifier(ours), ObjectIdentifier(theirs)])
        #expect(try sessions(.entry(slot)) == [ObjectIdentifier(ours)])
    }

    @Test
    func completionsAreFinishedSessionsOrCompletedEntries() throws {
        // The squat is completed on the seventh and only skipped on the eighth.
        let completed = try store.session(7) { $0.completeAndAdvance() }
        try store.session(8) { $0.skipAndAdvance() }
        let squat = try #require((store.workout.entries ?? []).sorted().first?.exercise)

        func completions(_ subject: History.Subject) throws -> [ObjectIdentifier] {
            try History(subject, among: store.sessions, at: calendar.date(16), calendar: calendar).allTime.completions.map { ObjectIdentifier($0.session) }
        }

        #expect(try completions(.workout(store.workout)).count == 2)
        #expect(try completions(.exercise(squat)) == [ObjectIdentifier(completed)])
    }

    @Test
    func recordRunsFromTheFirstSessionToTheEndOfToday() throws {
        try store.session(7)

        let recent = try history(at: calendar.date(16)).recent

        #expect(try recent.interval == DateInterval(start: calendar.date(7, hour: 0), end: calendar.date(17, hour: 0)))
    }

    @Test
    func sessionsAfterTodayAreNotOnRecord() throws {
        try store.session(7)
        try store.session(20)

        #expect(try history(at: calendar.date(16)).allTime.sessions.count == 1)
    }

    @Test
    func weeksAreWholeCalendarWeeks() throws {
        // Wednesday, Sep 16: four weeks from Monday, Aug 24, to the end of Sunday, Sep 20.
        let weeks = try history(at: calendar.date(16)).weeks(4)

        #expect(try weeks.period == DateInterval(start: calendar.date(24, month: 8, hour: 0), end: calendar.date(21, hour: 0)))
    }

    @Test
    func monthStillAheadHasNothingOnRecord() throws {
        try store.session(7)

        let october = try history(at: calendar.date(16)).month(containing: calendar.date(10, month: 10))

        #expect(october.interval.duration == 0)
        #expect(october.sessions.isEmpty)
    }

    @Test
    func yearsRunFromTheFirstSessionsToTheCurrentOne() throws {
        try store.session(7)

        #expect(try history(at: calendar.date(16)).years == 2026 ... 2026)
        #expect(try history(at: calendar.date(10, month: 2, year: 2027)).years == 2026 ... 2027)
        #expect(try History(.all, among: [], at: calendar.date(16), calendar: calendar).years == 2026 ... 2026)
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

    func history(at now: Date, calendar: Calendar? = nil) -> History {
        History(.all, among: sessions, at: now, calendar: calendar ?? self.calendar)
    }

    func month(_ month: Int, at now: Date) throws -> History.Window {
        try history(at: now).month(containing: calendar.date(10, month: month))
    }

    @Test
    func withoutSessionsThereIsNoStreak() throws {
        let allTime = try history(at: calendar.date(16)).allTime

        #expect(allTime.weekStreak.weeks == 0)
        #expect(allTime.longestWeekStreak == 0)
        #expect(allTime.lastCompletion?.date == nil)
    }

    @Test
    func unfinishedWeekDoesNotBreakTheStreak() throws {
        // Weeks of Aug 24, Aug 31 and Sep 7. Nothing yet in the week of Sep 14.
        try store.session(25, month: 8)
        try store.session(1)
        try store.session(9)

        #expect(try history(at: calendar.date(16)).allTime.weekStreak.weeks == 3)

        try store.session(15)

        #expect(try history(at: calendar.date(16)).allTime.weekStreak.weeks == 4)
    }

    @Test
    func emptyWeekBreaksTheStreak() throws {
        try store.session(1)
        try store.session(3)

        #expect(try history(at: calendar.date(16)).allTime.weekStreak.weeks == 0)
    }

    @Test
    func severalSessionsInOneWeekCountOnce() throws {
        for day in [7, 8, 9, 14] {
            try store.session(day)
        }

        #expect(try history(at: calendar.date(16)).allTime.weekStreak.weeks == 2)
    }

    @Test
    func runningSessionDoesNotCount() throws {
        try store.session(9)
        let running = try store.startSession()
        running.startDate = try calendar.date(15, hour: 8)

        #expect(try history(at: calendar.date(16)).allTime.weekStreak.weeks == 1)
    }

    @Test(arguments: [(2, 2), (1, 1)])
    func weeksStartOnTheCalendarsFirstWeekday(firstWeekday: Int, streak: Int) throws {
        // Sunday Sep 6 and Saturday Sep 12 are in different weeks when weeks start on Monday,
        // and in the same week when they start on Sunday.
        try store.session(6)
        try store.session(12)

        let calendar = Calendar.berlin(firstWeekday: firstWeekday)

        #expect(try history(at: calendar.date(13), calendar: calendar).allTime.weekStreak.weeks == streak)
    }

    @Test
    func streakSurvivesDaylightSavingTimeChanges() throws {
        // Daylight saving time ends on Sunday, Oct 25.
        try store.session(20, month: 10)
        try store.session(25, month: 10, hour: 22)
        try store.session(27, month: 10)
        try store.session(3, month: 11)

        #expect(try history(at: calendar.date(4, month: 11)).allTime.weekStreak.weeks == 3)
    }

    @Test
    func sessionsAreDatedByTheirRecordedTimeZone() throws {
        // Sunday 23:00 in New York is already Monday in Berlin, but it belongs to the week it was recorded in.
        try store.session(13, hour: 23, zone: "America/New_York")
        try store.session(7)

        #expect(try history(at: calendar.date(16)).allTime.weekStreak.weeks == 1)
    }

    @Test
    func recentSessionRecordedFurtherEastCounts() throws {
        // Trained in Berlin until 09:00, then flew to New York, where it's 05:00, two hours later.
        // By the clock it was recorded at, the session ended four hours from now.
        let session = try store.session(15)
        var newYork = calendar
        newYork.timeZone = try #require(TimeZone(identifier: "America/New_York"))

        let allTime = try history(at: newYork.date(15, hour: 5), calendar: newYork).allTime

        #expect(allTime.weekStreak.weeks == 1)
        #expect(allTime.lastCompletion?.date == session.endDate)
    }

    @Test(arguments: [(8, 2), (9, 4)])
    func streakIsAsOfTheEndOfTheWindowOrTodayWhileItsOngoing(month: Int, streak: Int) throws {
        // Weeks of Aug 24, Aug 31, Sep 7 and Sep 14, viewed on Sep 16. September's end is still weeks away.
        for (day, month) in [(24, 8), (31, 8), (7, 9), (15, 9)] {
            try store.session(day, month: month)
        }

        #expect(try self.month(month, at: calendar.date(16)).weekStreak.weeks == streak)
    }

    @Test
    func pastWindowKeepsTheStreakItEndedWith() throws {
        // Every week from Apr 27 to the week of Jun 1. The session on Jun 2 doesn't count for May.
        for (day, month) in [(28, 4), (5, 5), (12, 5), (19, 5), (26, 5), (2, 6)] {
            try store.session(day, month: month)
        }

        let may = try month(5, at: calendar.date(10, month: 6))

        #expect(may.weekStreak.weeks == 5)
        #expect(may.longestWeekStreak == 5)
        #expect(try history(at: calendar.date(10, month: 6)).allTime.weekStreak.weeks == 6)
    }

    @Test
    func pastWindowIsAsSeenOnItsLastDay() throws {
        // Every week from Apr 27 to May 18. On Sunday, May 31, the week of May 25 isn't over yet.
        for (day, month) in [(28, 4), (5, 5), (12, 5), (19, 5)] {
            try store.session(day, month: month)
        }

        #expect(try month(5, at: calendar.date(10, month: 6)).weekStreak.weeks == 4)
    }

    @Test
    func longestStreakIsTheBestOneWhenTheWindowEnded() throws {
        // Five weeks from Jul 6 to Aug 3, a gap, then four weeks from Sep 7 to Sep 28.
        for (day, month) in [(6, 7), (13, 7), (20, 7), (27, 7), (3, 8), (7, 9), (14, 9), (21, 9), (28, 9)] {
            try store.session(day, month: month)
        }

        let september = try month(9, at: calendar.date(16, month: 10))

        #expect(september.weekStreak.weeks == 4)
        #expect(september.longestWeekStreak == 5)
    }

    @Test
    func windowStillAheadHasNoStreak() throws {
        try store.session(7)
        try store.session(14)

        let october = try month(10, at: calendar.date(16))

        #expect(october.weekStreak.weeks == 0)
        #expect(october.longestWeekStreak == 0)
    }

    @Test
    func longestStreakCountsItsWeeksBeforeTheWindow() throws {
        // Weeks of Aug 24, Aug 31 and Sep 7, a gap, then the week of Sep 21.
        try store.session(24, month: 8)
        try store.session(1)
        try store.session(7)
        try store.session(22)

        let september = try month(9, at: calendar.date(23))

        #expect(september.longestWeekStreak == 3)
        #expect(september.weekStreak.weeks == 1)
    }

    @Test
    func longestStreakDoesNotCountWeeksAfterTheWindow() throws {
        // Weeks of Aug 24, Aug 31, Sep 7 and Sep 14.
        for (day, month) in [(24, 8), (31, 8), (7, 9), (14, 9)] {
            try store.session(day, month: month)
        }

        #expect(try month(8, at: calendar.date(16)).longestWeekStreak == 2)
    }

    /// A finished session of another workout, so that there is something to be favourite over.
    @discardableResult
    func session(of workout: Workout, day: Int, month: Int = 9, hour: Int = 8) throws -> Session {
        let session = try #require(workout.startSession())
        session.startDate = try calendar.date(day, month: month, hour: hour)
        session.endDate = session.startDate.addingTimeInterval(3600)
        return session
    }

    /// A second workout of the store's own exercises.
    func workout(_ name: String) -> Workout {
        let workout = Workout(name: name, pictogram: .workout, schedule: .inactive, entries: [])
        store.context.insert(workout)
        return workout
    }

    @Test
    func completionsCountTheFinishedSessionsOfTheWindow() throws {
        try store.session(31, month: 8)
        try store.session(7)
        try store.session(8)
        _ = try store.startSession()

        #expect(try history(at: calendar.date(16)).allTime.completionCount == 3)
        #expect(try month(9, at: calendar.date(16)).completionCount == 2)
    }

    @Test
    func withoutSessionsThereIsNoFavouriteWorkout() throws {
        let allTime = try history(at: calendar.date(16)).allTime

        #expect(allTime.completionCount == 0)
        #expect(allTime.favoriteWorkout == nil)
    }

    @Test
    func favoriteWorkoutIsTheOneDoneMostOften() throws {
        let legs = workout("Leg Day")
        try store.session(7)
        try store.session(8)
        try session(of: legs, day: 9)

        let allTime = try history(at: calendar.date(16)).allTime

        #expect(allTime.favoriteWorkout === store.workout)
        #expect(StatisticKind.favoriteWorkout.reading(in: allTime)?.formatted(.reading(units: .metric)) == store.workout.name)
    }

    @Test
    func workoutsLevelOnCountGoToTheOneDoneLast() throws {
        let legs = workout("Leg Day")
        try store.session(7)
        try session(of: legs, day: 8)

        #expect(try history(at: calendar.date(16)).allTime.favoriteWorkout === legs)

        try store.session(9)
        try session(of: legs, day: 10)
        try store.session(11)

        // Three each now, and the full body one was the last of them.
        #expect(try history(at: calendar.date(16)).allTime.favoriteWorkout === store.workout)
    }

    @Test
    func favoriteWorkoutCountsOnlyTheWindowsSessions() throws {
        let legs = workout("Leg Day")
        try session(of: legs, day: 25, month: 8)
        try session(of: legs, day: 26, month: 8)
        try store.session(7)

        #expect(try month(9, at: calendar.date(16)).favoriteWorkout === store.workout)
        #expect(try history(at: calendar.date(16)).allTime.favoriteWorkout === legs)
    }

    @Test
    func favoriteExerciseIsTheOneCompletedMostOften() throws {
        // The squat is completed twice, the bench press once and skipped once.
        try store.session(7) { session in
            session.completeAndAdvance()
            session.completeAndAdvance()
        }
        try store.session(8) { session in
            session.completeAndAdvance()
            session.skipAndAdvance()
        }

        let allTime = try history(at: calendar.date(16)).allTime

        #expect(StatisticKind.favoriteExercise.reading(in: allTime)?.formatted(.reading(units: .metric)) == "Squat")
        #expect(try history(at: calendar.date(16)).recent.favoriteExercise === allTime.favoriteExercise)
    }

    @Test
    func exercisesLevelOnCountGoToTheOneCompletedLast() throws {
        let session = try store.session(7)
        let entries = (session.entries ?? []).sorted()
        entries[1].status = .completed(date: session.startDate.addingTimeInterval(60))
        entries[0].status = .completed(date: session.startDate.addingTimeInterval(120))

        // Once each, and the squat was completed after the bench press.
        #expect(try StatisticKind.favoriteExercise.reading(in: history(at: calendar.date(16)).allTime)?.formatted(.reading(units: .metric)) == "Squat")
    }

    @Test
    func withoutSessionsThereIsNoTypicalSessionEither() throws {
        let allTime = try history(at: calendar.date(16)).allTime

        #expect(allTime.typicalDuration == nil)
        #expect(allTime.typicalStartTime == nil)
    }

    @Test
    func typicalSessionIsTheMedianLengthAndARecordedStartTime() throws {
        for (day, hour, minutes) in [(7, 7, 30), (8, 8, 60), (9, 19, 120)] {
            try store.session(day, hour: hour, minutes: minutes)
        }

        let allTime = try history(at: calendar.date(16)).allTime

        // The middle of 30, 60 and 120 minutes, started at the recorded time closest to all the others.
        #expect(allTime.typicalDuration == 3600)
        #expect(allTime.typicalStartTime == 8 * 60)
    }

    @Test
    func typicalSessionCountsOnlyTheWindowsSessions() throws {
        try store.session(31, month: 8, hour: 7, minutes: 30)
        try store.session(7, hour: 19, minutes: 90)

        let september = try month(9, at: calendar.date(16))

        #expect(september.typicalDuration == 90.0 * 60)
        #expect(september.typicalStartTime == 19 * 60)
    }

    @Test
    func withoutSessionsThereAreNoWeeklySessions() throws {
        #expect(try history(at: calendar.date(16)).allTime.weeklySessions == nil)
    }

    @Test
    func weeklySessionsCountFromTheFirstSessionToToday() throws {
        // Four sessions over the two weeks from Sep 1 through Sep 14.
        for day in [1, 3, 8, 10] {
            try store.session(day)
        }

        #expect(try history(at: calendar.date(14)).allTime.weeklySessions == 2)
    }

    @Test
    func weeklySessionsCoverAtLeastAWeek() throws {
        try store.session(15)

        #expect(try history(at: calendar.date(16)).allTime.weeklySessions == 1)
    }

    @Test
    func weeklySessionsCountTheDaysOfTheWindowSinceTheFirstSession() throws {
        // September started before Sep 8 and is ongoing, so it covers the two weeks from Sep 8 through Sep 21.
        try store.session(8)
        try store.session(10)

        #expect(try month(9, at: calendar.date(21)).weeklySessions == 1)
    }

    @Test
    func pastWindowCountsItsWholeLengthForWeeklySessions() throws {
        // August has 31 days. The sessions in July and September only mark when training began and don't count.
        for (day, month) in [(20, 7), (3, 8), (17, 8), (7, 9)] {
            try store.session(day, month: month)
        }

        let rate = try #require(try month(8, at: calendar.date(16)).weeklySessions)

        #expect(abs(rate - 2 / (31.0 / 7)) < 1e-9)
    }

    @Test
    func recentDaysWithoutSessionsAreNoneAWeek() throws {
        // Trained in June, then nothing: the last four weeks are on record, just empty.
        try store.session(10, month: 6)

        #expect(try history(at: calendar.date(16)).recent.weeklySessions == 0)
    }

    @Test
    func windowStillAheadHasNoWeeklySessions() throws {
        try store.session(7)

        #expect(try month(10, at: calendar.date(16)).weeklySessions == nil)
    }

    @Test
    func windowIsHalfOpen() throws {
        // Starts exactly at midnight on Oct 1, so it belongs to October only.
        try store.session(1, month: 10, hour: 0)

        let now = try calendar.date(16, month: 10)

        #expect(try month(9, at: now).lastCompletion?.date == nil)
        #expect(try month(10, at: now).lastCompletion?.date != nil)
    }

    @Test
    func sessionBelongsToTheWindowItStartedIn() throws {
        // Starts on Sep 30 at 23:30 and ends in October.
        try store.session(30, hour: 23, minute: 30)

        let now = try calendar.date(16, month: 10)

        #expect(try month(9, at: now).lastCompletion?.date != nil)
        #expect(try month(10, at: now).lastCompletion?.date == nil)
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

    func history() throws -> History {
        try History(.workout(store.workout), among: store.sessions, at: calendar.date(16, month: 10), calendar: calendar)
    }

    @Test
    func workoutWithoutSessionsHasNoValues() throws {
        let allTime = try history().allTime

        #expect(allTime.lastCompletion?.date == nil)
        #expect(allTime.completionCount == 0)
        #expect(allTime.completionRate == nil)
        #expect(allTime.typicalDuration == nil)
        #expect(allTime.typicalStartTime == nil)
        #expect(allTime.mostSkippedExercise == nil)
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

        let allTime = try history().allTime

        #expect(allTime.completionCount == 2)
        #expect(StatisticKind.mostSkippedExercise.reading(in: allTime)?.formatted(.reading(units: .metric)) == "Bench Press")
        #expect(try allTime.lastCompletion?.date == calendar.date(8, hour: 9))
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
        #expect(try history().allTime.completionRate == 4.0 / 6.0)
    }

    @Test
    func typicalDurationIsTheMedian() throws {
        for (day, minutes) in [(7, 30), (8, 60), (9, 120)] {
            try store.session(day, minutes: minutes)
        }

        #expect(try history().allTime.typicalDuration == 3600)
    }

    @Test
    func typicalStartTimeIsARecordedStartTime() throws {
        for (day, hour, minute) in [(7, 7, 0), (8, 8, 15), (9, 19, 30)] {
            try store.session(day, hour: hour, minute: minute)
        }

        #expect(try history().allTime.typicalStartTime == 8 * 60 + 15)
    }

    @Test
    func typicalStartTimeIsNeverBetweenTwoStartTimes() throws {
        // An even count: the middle of 07:00 and 19:30 is 13:15, which was never trained at.
        try store.session(7, hour: 7)
        try store.session(8, hour: 19, minute: 30)

        #expect(try history().allTime.typicalStartTime == 7 * 60)
    }

    @Test
    func typicalStartTimeWrapsAroundMidnight() throws {
        // 23:30 and 00:30 are an hour apart on the clock, so neither midday nor anything between them.
        try store.session(7, hour: 23, minute: 30)
        try store.session(9, hour: 0, minute: 30)
        try store.session(10, hour: 0, minute: 30)

        #expect(try history().allTime.typicalStartTime == 30)
    }

    @Test
    func typicalStartTimeUsesTheRecordedTimeZone() throws {
        // 08:00 in New York is 14:00 in Berlin, but the user saw 08:00.
        try store.session(7, hour: 8)
        try store.session(8, hour: 8, zone: "America/New_York")

        #expect(try history().allTime.typicalStartTime == 8 * 60)
    }

    @Test
    func lastCompletedShowsTheDayItStartedOnItsClock() throws {
        // Runs from 23:30 on May 28 to 00:30 on May 29 in New York. It started at 05:30 on May 29 in Berlin.
        try store.session(28, month: 5, hour: 23, minute: 30, zone: "America/New_York")
        let value = try StatisticKind.lastCompleted.reading(in: history().allTime)?.formatted(.reading(units: .metric))

        #expect(try value == Reading.day(calendar.date(28, month: 5), calendar: calendar).formatted(.reading(units: .metric)))
        #expect(try value != Reading.day(calendar.date(29, month: 5), calendar: calendar).formatted(.reading(units: .metric)))
    }

    @Test
    func onlySessionsWithinTheWindowCount() throws {
        try store.session(31, month: 8)
        try store.session(7)
        try store.session(14)
        try store.session(1, month: 10)

        let september = try history().month(containing: calendar.date(10))

        #expect(september.completionCount == 2)
        #expect(try september.lastCompletion?.date == calendar.date(14, hour: 9))
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
        self.squat = try #require((store.workout.entries ?? []).sorted().first?.exercise)
    }

    func history() throws -> History {
        try History(.exercise(squat), among: store.sessions, at: calendar.date(16, month: 10), calendar: calendar)
    }

    @Test
    func exerciseWithoutSessionsHasNoValues() throws {
        let allTime = try history().allTime

        #expect(allTime.lastCompletion?.date == nil)
        #expect(allTime.completionRate == nil)
        #expect(allTime.personalBest == nil)
        #expect(allTime.completionCount == 0)
        #expect(StatisticKind.completions.reading(in: allTime)?.formatted(.reading(units: .metric)) == "0")
    }

    @Test
    func onlyFinishedSessionsCount() throws {
        try store.session(7) { $0.completeAndAdvance() }
        let running = try store.startSession()
        running.skipAndAdvance()

        let allTime = try history().allTime

        #expect(allTime.completionCount == 1)
        #expect(allTime.completionRate == 1)
        #expect(allTime.lastCompletion?.date != nil)
    }

    @Test
    func skippedEntriesLowerTheCompletionRate() throws {
        try store.session(7) { $0.completeAndAdvance() }
        try store.session(8) { $0.skipAndAdvance() }

        let allTime = try history().allTime

        #expect(allTime.completionCount == 1)
        #expect(allTime.completionRate == 0.5)
    }

    @Test
    func lastCompletedIsTheLastTimeItWasCompletedAndNotSkipped() throws {
        let completed = try store.session(7) { $0.completeAndAdvance() }
        try store.session(8) { $0.skipAndAdvance() }
        let entry = try #require((completed.entries ?? []).sorted().first)

        #expect(try history().allTime.lastCompletion?.date == entry.status.resolvedDate)
    }

    @Test
    func onlySessionsWithinTheWindowCount() throws {
        try store.session(31, month: 8) { $0.completeAndAdvance() }
        try store.session(7) { $0.skipAndAdvance() }

        let september = try history().month(containing: calendar.date(10))

        #expect(september.completionCount == 0)
        #expect(september.completionRate == 0)
        #expect(september.personalBest == nil)
    }

    @Test
    func personalBestIgnoresTargetsOfAnotherType() throws {
        try store.session(7) { $0.completeAndAdvance() }

        #expect(try history().allTime.personalBest?.bodyweightTarget == .init(sets: 3, reps: 10))

        squat.kind = .weight

        #expect(try history().allTime.personalBest == nil)
    }

    @Test
    func bestsOnlyMeanSomethingForAnExercise() throws {
        try store.session(7) { $0.completeAndAdvance() }

        let workout = try History(.workout(store.workout), among: store.sessions, at: calendar.date(16, month: 10), calendar: calendar).allTime

        #expect(workout.personalBest == nil)
        #expect(workout.typicalBest == nil)
    }
}

// MARK: - Trend

@MainActor
struct TrendTests {
    let store: TestStore

    let calendar = Calendar.berlin()

    init() throws {
        self.store = try TestStore()
    }

    func history(at now: Date) -> History {
        History(.workout(store.workout), among: store.sessions, at: now, calendar: calendar)
    }

    func trend(of kind: StatisticKind, at now: Date) -> Trend? {
        guard case let .metric(_, tolerance, _, value) = kind.definition.value else {
            return nil
        }

        return Trend(history(at: now), tolerance: tolerance, perSession: kind.isPerSession, value: value)
    }

    @Test
    func trendNeedsThreeSessionsInTheDaysBefore() throws {
        // Read on Sep 16, the recent days start on Aug 20 and the ones before on May 28.
        try store.session(10, month: 7)
        try store.session(20, month: 7)
        try store.session(7)

        #expect(try #require(trend(of: .weeklySessions, at: calendar.date(16))).before == nil)

        try store.session(30, month: 7)

        #expect(try #require(trend(of: .weeklySessions, at: calendar.date(16))).before != nil)
    }

    @Test
    func trendNeedsThreeValuesInTheDaysBefore() throws {
        // Three sessions before the recent days, but only two of them were recorded with a heart rate.
        for (day, heartRate) in [(10, 120.0), (20, 130), (30, nil)] {
            try store.session(day, month: 7).health = Session.HealthSummary(averageHeartRate: heartRate)
        }

        try store.session(7).health = Session.HealthSummary(averageHeartRate: 110)

        #expect(try #require(trend(of: .typicalHeartRate, at: calendar.date(16))).before == nil)

        try store.session(30, month: 6).health = Session.HealthSummary(averageHeartRate: 125)

        #expect(try #require(trend(of: .typicalHeartRate, at: calendar.date(16))).before == 125)
    }

    @Test
    func countsDoNotCompare() throws {
        for (day, month) in [(10, 7), (20, 7), (30, 7), (7, 9)] {
            try store.session(day, month: month)
        }

        let trend = try #require(self.trend(of: .completions, at: calendar.date(16)))

        #expect(trend.recent == 1)
        #expect(trend.before == nil)
        #expect(trend.direction == nil)
    }

    @Test
    func directionComparesTheRecentDaysWithTheOnesBefore() throws {
        // Three sessions over the six weeks from Jul 10, then one a week over the last four.
        for (day, month) in [(10, 7), (20, 7), (30, 7), (24, 8), (31, 8), (7, 9), (14, 9)] {
            try store.session(day, month: month)
        }

        let trend = try #require(self.trend(of: .weeklySessions, at: calendar.date(16)))

        #expect(trend.recent == 1)
        #expect(trend.direction == .up)
    }

    @Test(arguments: [(1.0, 1.04, Trend.Direction.flat), (1, 0.96, .flat), (1, 1.2, .up), (1, 0.8, .down), (0, 0, .flat), (0, 1, .up)])
    func directionIsFlatWithinTheTolerance(old: Double, new: Double, direction: Trend.Direction) {
        #expect(Trend.Direction(from: old, to: new, tolerance: 0.05) == direction)
    }

    @Test
    func directionNeedsBothValues() {
        #expect(Trend.Direction(from: nil, to: 1, tolerance: 0.05) == nil)
        #expect(Trend.Direction(from: 1, to: nil, tolerance: 0.05) == nil)
    }

    @Test
    func monthsWithoutADayOnRecordHaveNoBar() throws {
        try store.session(7, month: 3)

        let series = try Series(history(at: calendar.date(16)), year: 2026, value: \.completionCount)

        // March, the first on record, through September, the current one.
        #expect(try series.bars.map(\.month) == (3 ... 9).map { try calendar.date(1, month: $0, hour: 0) })
        #expect(series.bars.map(\.value) == [1, 0, 0, 0, 0, 0, 0])
        #expect(try series.period == DateInterval(start: calendar.date(1, month: 1, hour: 0), end: calendar.date(1, month: 1, year: 2027, hour: 0)))
    }
}

// MARK: - Session figures

@MainActor
struct SessionFigureTests {
    let store: TestStore

    let calendar = Calendar.berlin()

    init() throws {
        self.store = try TestStore()
    }

    /// Completes the session's exercises in order, at the given offsets in minutes from when it started.
    func resolve(_ session: Session, after offsets: [Int]) {
        for (entry, offset) in zip((session.entries ?? []).sorted(), offsets) {
            entry.status = .completed(date: session.startDate.addingTimeInterval(TimeInterval(offset * 60)))
        }
    }

    @Test
    func unfinishedSessionHasNoDurationOrEndTime() throws {
        let unfinished = try store.startSession()

        #expect(unfinished.duration == nil)
        #expect(SessionFigureKind.endTime.reading(of: unfinished) == nil)
        #expect(unfinished.typicalExerciseDuration == nil)
        #expect(unfinished.skipRate == 0)
    }

    @Test
    func durationIsTheTimeFromStartToFinish() throws {
        #expect(try store.session(7, minutes: 45).duration == 45 * 60)
    }

    /// Gives the session's exercises weight targets, in workout order, and completes them.
    func load(_ session: Session, kilograms: [Double], sets: Int = 3, reps: Int = 10) {
        for (entry, weight) in zip((session.entries ?? []).sorted(), kilograms) {
            entry.target = .weight(kilograms: weight, reps: reps, sets: sets)
            entry.status = .completed(date: session.startDate)
        }
    }

    @Test
    func completedExercisesCountsOnlyTheCompletedOnes() throws {
        let session = try store.session(7) { session in
            session.completeAndAdvance()
            session.skipAndAdvance()
        }

        // One completed, one skipped, one left pending.
        #expect(session.completedExerciseCount == 1)
    }

    @Test
    func totalVolumeIsLoadTimesSetsTimesReps() throws {
        let session = try store.session(7)
        load(session, kilograms: [100, 50], sets: 3, reps: 10)

        // 100 x 3 x 10 plus 50 x 3 x 10, with the third exercise left pending.
        #expect(session.volume == 4500)
    }

    @Test
    func totalVolumeLeavesOutSkippedExercises() throws {
        let session = try store.session(7)
        load(session, kilograms: [100, 50], sets: 1, reps: 1)
        let skipped = try #require((session.entries ?? []).sorted().last)
        skipped.target = .weight(kilograms: 999, reps: 1, sets: 1)
        skipped.status = .skipped(date: session.startDate)

        #expect(session.volume == 150)
    }

    @Test
    func sessionWithoutWeightedExercisesHasNoVolume() throws {
        let session = try store.session(7) { session in
            session.completeAndAdvance()
            session.completeAndAdvance()
            session.completeAndAdvance()
        }

        // The store's exercises are all bodyweight, which carries no load, so there is nothing to total.
        #expect(session.completedExerciseCount == 3)
        #expect(session.volume == nil)
        #expect(SessionFigureKind.volume.reading(of: session)?.formatted(.reading(units: .metric)) == nil)
    }

    @Test
    func totalVolumeReadsAsAWeight() throws {
        let session = try store.session(7)
        let entry = try #require((session.entries ?? []).sorted().first)
        entry.target = .weight(kilograms: 100, reps: 5, sets: 2)
        entry.status = .completed(date: session.startDate)

        #expect(session.volume == 1000)
        #expect(SessionFigureKind.volume.reading(of: session) == .weight(kilograms: 1000))
    }

    @Test
    func skipRateCountsEveryExerciseOfTheSession() throws {
        let session = try store.session(7) { session in
            session.skipAndAdvance()
            session.completeAndAdvance()
        }

        // One skipped and one completed of three, with the last one left pending.
        #expect(session.skipRate == 1.0 / 3.0)
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
        let durations: [TimeInterval] = (session.entries ?? []).sorted().compactMap(\.duration)

        // In workout order: the first was resolved last, so it took the 40 minutes since the one before it.
        #expect(durations == [2400, 600, 600])
    }

    @Test
    func medianExerciseDurationIsTheMiddleOfTheExerciseDurations() throws {
        let session = try store.session(7, minutes: 90)
        resolve(session, after: [10, 20, 60])

        // 10, 10 and 40 minutes, so the middle one is what a typical exercise took.
        #expect(session.typicalExerciseDuration == 10.0 * 60)
    }

    @Test
    func medianExerciseDurationIsNotSkewedByOneLongGap() throws {
        let early = try store.session(7, minutes: 90)
        let late = try store.session(8, minutes: 90)
        resolve(early, after: [0, 10, 20])
        resolve(late, after: [40, 50, 60])

        // The late one spent 40 minutes before its first exercise, which a mean would have spread over all three.
        #expect(early.typicalExerciseDuration == 10.0 * 60)
        #expect(late.typicalExerciseDuration == early.typicalExerciseDuration)
    }

    @Test
    func medianExerciseDurationSplitsAnEvenCount() throws {
        let session = try store.session(7, minutes: 90)
        resolve(session, after: [10, 30])

        // 10 and 20 minutes, so it lands between them.
        #expect(session.typicalExerciseDuration == 15.0 * 60)
    }

    @Test
    func medianExerciseDurationNeedsAResolvedExercise() throws {
        let session = try store.session(7, minutes: 90)

        #expect(session.typicalExerciseDuration == nil)

        resolve(session, after: [15])

        // A single resolved exercise still counts, from the start of the session.
        #expect(session.typicalExerciseDuration == 15.0 * 60)
    }

    @Test
    func shortExercisesAreReadInSecondsAndNotAsNoTimeAtAll() throws {
        let session = try store.session(7, minutes: 90)
        resolve(session, after: [0, 0, 0])
        let quick = try #require((session.entries ?? []).sorted().first)
        quick.status = .completed(date: session.startDate.addingTimeInterval(40))

        #expect(quick.duration == 40)
        #expect(SessionFigureKind.exerciseDuration.reading(of: session) == .duration(seconds: 0))
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

        #expect(SessionFigureKind.endTime.reading(of: session)?.formatted(.reading(units: .metric)) == ended.formatted(inNewYork))
        #expect(SessionFigureKind.endTime.reading(of: session)?.formatted(.reading(units: .metric)) != ended.formatted(inBerlin))
    }
}

// MARK: - Session entry

@MainActor
struct SessionEntryComparisonTests {
    let store: TestStore

    let squat: Exercise

    init() throws {
        self.store = try TestStore()
        self.squat = try #require((store.workout.entries ?? []).sorted().first?.exercise)
    }

    /// The squat entry of a session completed on the given day, at the given number of reps.
    @discardableResult
    func squatSession(_ day: Int, reps: Int) throws -> SessionEntry {
        let session = try store.session(day)
        let entry = try #require((session.entries ?? []).sorted().first)
        entry.target = .bodyweight(reps: reps, sets: 3)
        entry.status = .completed(date: session.startDate)
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
        let entry = try #require((session.entries ?? []).sorted().first)
        entry.target = .bodyweight(reps: 20, sets: 3)
        entry.status = .skipped(date: session.startDate)

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

        #expect(try #require((running.entries ?? []).sorted().first).isBest == false)
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
        entry.status = try .skipped(date: #require(entry.session).startDate)

        #expect(entry.previous == nil)
        #expect(entry.previousBest == nil)
    }

    @Test
    func differenceReadsInTheReadersUnits() throws {
        squat.kind = .weight
        let earlier = try store.session(7)
        let later = try store.session(8)

        for (session, kilograms) in [(earlier, 100.0), (later, 102.5)] {
            let entry = try #require((session.entries ?? []).sorted().first)
            entry.target = .weight(kilograms: kilograms, reps: 5, sets: 3)
            entry.status = .completed(date: session.startDate)
        }

        let entry = try #require((later.entries ?? []).sorted().first)
        let previous = try #require(entry.previous)

        #expect(Reading(rank: entry.target.rank - previous.rank, of: entry.target.exerciseKind) == .weight(kilograms: 2.5))
    }

    @Test
    func targetsOfAnotherTypeAreNotComparable() throws {
        try squatSession(7, reps: 10)
        let entry = try squatSession(8, reps: 12)

        // The exercise is a weight exercise now, so neither bodyweight target can be ranked against it.
        squat.kind = .weight

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
        self.squat = try #require((store.workout.entries ?? []).sorted().first?.exercise)
        squat.kind = .weight
    }

    /// Completes the given slot of a session of `workout` on the given day, at the given weight.
    @discardableResult
    func lift(_ slot: WorkoutEntry, of workout: Workout, day: Int, kilograms: Double) throws -> SessionEntry {
        let session = try #require(workout.startSession())
        let entry = try #require((session.entries ?? []).first { $0.workoutEntry === slot })
        entry.target = .weight(kilograms: kilograms, reps: 5, sets: 3)
        entry.status = try .completed(date: Calendar.berlin().date(day))
        session.startDate = try Calendar.berlin().date(day)
        session.endDate = session.startDate
        return entry
    }

    @Test
    func trendIgnoresTheSameExerciseInAnotherWorkout() throws {
        // A warmup at 40 kg in one workout, the real thing at 100 then 102.5 kg in another.
        let warmups = Workout(name: "Warmup", pictogram: .workout, schedule: .inactive, entries: [])
        store.context.insert(warmups)
        warmups.append(exercise: squat, target: .weight(kilograms: 40, reps: 5, sets: 1))

        let warmupSlot = try #require((warmups.entries ?? []).sorted().first)
        let mainSlot = try #require((store.workout.entries ?? []).sorted().first)

        try lift(mainSlot, of: store.workout, day: 7, kilograms: 100)
        try lift(warmupSlot, of: warmups, day: 8, kilograms: 40)
        let main = try lift(mainSlot, of: store.workout, day: 9, kilograms: 102.5)

        // Without slot scoping the previous time would be the warmup at 40 kg.
        #expect(try #require(main.previous).rank == 100)
    }

    @Test
    func trendKeepsTheTwoSlotsOfOneWorkoutApart() throws {
        // The same exercise twice in one workout: a light opener and a heavy set.
        store.workout.append(exercise: squat, target: .weight(kilograms: 60, reps: 5, sets: 1))

        let slots = (store.workout.entries ?? []).filter { $0.exercise === squat }.sorted()
        let heavy = try #require(slots.first)
        let light = try #require(slots.last)

        #expect(slots.count == 2)

        try lift(heavy, of: store.workout, day: 7, kilograms: 100)
        try lift(light, of: store.workout, day: 7, kilograms: 60)
        let laterHeavy = try lift(heavy, of: store.workout, day: 8, kilograms: 105)

        #expect(try #require(laterHeavy.previous).rank == 100)
    }

    @Test
    func personalBestIsScopedToTheSlotToo() throws {
        let warmups = Workout(name: "Warmup", pictogram: .workout, schedule: .inactive, entries: [])
        store.context.insert(warmups)
        warmups.append(exercise: squat, target: .weight(kilograms: 40, reps: 5, sets: 1))

        let warmupSlot = try #require((warmups.entries ?? []).sorted().first)
        let mainSlot = try #require((store.workout.entries ?? []).sorted().first)

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
        #expect(try #require(lighter.previous).rank == 45)
        #expect(try #require(lighter.previousBest).rank == 45)
    }
}

// MARK: - Current highest target

@MainActor
struct ExerciseCurrentHighestTargetTests {
    let store: TestStore

    let squat: Exercise

    init() throws {
        self.store = try TestStore()
        self.squat = try #require((store.workout.entries ?? []).sorted().first?.exercise)
    }

    /// A second workout holding the squat at the given number of reps.
    @discardableResult
    func workout(_ name: String, reps: Int) throws -> Workout {
        let workout = Workout(name: name, pictogram: .workout, schedule: .inactive, entries: [])
        store.context.insert(workout)
        workout.append(exercise: squat, target: .bodyweight(reps: reps, sets: 3))
        return workout
    }

    @Test
    func anExerciseInNoWorkoutHasNothingToGoOn() {
        let rows = Exercise(name: "Rows", kind: .bodyweight, categories: [])
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
        let entry = try #require((session.entries ?? []).first { $0.exercise === squat })
        entry.target = .bodyweight(reps: 20, sets: 3)
        entry.status = .completed(date: .now)
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
        squat.kind = .weight

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
        self.squat = try #require((store.workout.entries ?? []).sorted().first?.exercise)
    }

    func history() throws -> History {
        try History(.exercise(squat), among: store.sessions, at: calendar.date(16, month: 10), calendar: calendar)
    }

    func progression() throws -> Progression {
        try Progression(history().allTime)
    }

    /// A session with its squat completed at the given number of reps.
    @discardableResult
    func squatSession(_ day: Int, month: Int = 9, hour: Int = 8, reps: Int) throws -> Session {
        let session = try store.session(day, month: month, hour: hour)
        let entry = try #require((session.entries ?? []).sorted().first)
        entry.target = .bodyweight(reps: reps, sets: 3)
        entry.status = .completed(date: session.startDate)
        return session
    }

    @Test
    func exerciseWithoutCompletionsHasNoPoints() throws {
        #expect(try progression().points.isEmpty)
        #expect(try progression().curve.isEmpty)
    }

    @Test
    func everyDayItWasCompletedOnIsAPoint() throws {
        try squatSession(7, reps: 10)
        try squatSession(9, reps: 12)

        let points = try progression().points

        #expect(points.map(\.target.rank) == [10, 12])
        #expect(try points.map(\.date) == [calendar.date(7, hour: 0), calendar.date(9, hour: 0)])
    }

    @Test
    func pointsAreOldestFirst() throws {
        try squatSession(9, reps: 12)
        try squatSession(7, reps: 10)

        #expect(try progression().points.map(\.target.rank) == [10, 12])
    }

    @Test
    func aDayIsOnePointAtItsBest() throws {
        // A warmup in the morning and the real thing in the evening: the day is worth what it got to.
        try squatSession(7, hour: 8, reps: 5)
        try squatSession(7, hour: 18, reps: 12)

        #expect(try progression().points.map(\.target.rank) == [12])
    }

    @Test
    func skippedAndPendingExercisesAreNoPoints() throws {
        try store.session(7) { $0.skipAndAdvance() }
        try store.session(8)

        #expect(try progression().points.isEmpty)
    }

    @Test
    func runningSessionsAreNoPoints() throws {
        let running = try store.startSession()
        running.completeAndAdvance()

        #expect(try progression().points.isEmpty)
    }

    @Test
    func targetsOfAnotherTypeAreLeftOut() throws {
        try squatSession(7, reps: 10)

        #expect(try progression().points.count == 1)

        // Reps say nothing about how heavy the exercise is now measured in.
        squat.kind = .weight

        #expect(try progression().points.isEmpty)
    }

    @Test
    func onlySessionsWithinTheWindowCount() throws {
        try squatSession(31, month: 8, reps: 10)
        try squatSession(7, reps: 12)

        let september = try history().month(containing: calendar.date(10))

        #expect(Progression(september).points.map(\.target.rank) == [12])
    }

    @Test
    func pointsAreDatedByTheClockTheyWereRecordedOn() throws {
        // Sunday 23:00 in New York is already Monday in Berlin, but the user trained on Sunday.
        let session = try store.session(13, hour: 23, zone: "America/New_York")
        let entry = try #require((session.entries ?? []).sorted().first)
        entry.status = .completed(date: session.startDate)

        #expect(try progression().points.map(\.date) == [calendar.date(13, hour: 0)])
    }

    @Test
    func typicalBestIsTheMiddleDayAndOneActuallyDone() throws {
        // An even count: the middle of 12 and 14 would be 13, which was never done.
        for (day, reps) in [(7, 10), (8, 14), (9, 12), (10, 20)] {
            try squatSession(day, reps: reps)
        }

        let allTime = try history().allTime

        #expect(allTime.typicalBest?.bodyweightTarget?.reps == 12)
        #expect(allTime.personalBest?.bodyweightTarget?.reps == 20)
    }

    @Test
    func curveEndsOnTheRecentTypicalBest() throws {
        // Read on Oct 16, the last four weeks start on Sep 19.
        for (day, month, reps) in [(10, 9, 30), (20, 9, 10), (1, 10, 12), (10, 10, 14)] {
            try squatSession(day, month: month, reps: reps)
        }

        let history = try history()
        let last = try #require(Progression(history.allTime).curve.last)

        #expect(try last.date == calendar.date(16, month: 10, hour: 0))
        #expect(last.target.bodyweightTarget?.reps == history.recent.typicalBest?.bodyweightTarget?.reps)
        #expect(last.target.bodyweightTarget?.reps == 12)
    }

    @Test
    func curveLooksBackBeforeTheWindow() throws {
        try squatSession(20, reps: 10)
        try squatSession(10, month: 10, reps: 14)

        let october = try Progression(history().month(containing: calendar.date(10, month: 10)))

        // October's first week still has September's day to go on, though it isn't one of October's points.
        #expect(october.points.map(\.target.rank) == [14])
        #expect(october.curve.first?.target.bodyweightTarget?.reps == 10)
    }

    @Test
    func curveWithoutPointsStillReadsInTheExercisesUnit() throws {
        try squatSession(20, reps: 10)

        let october = try Progression(history().month(containing: calendar.date(10, month: 10)))

        // October's curve looks back at September, but it has no point of its own to tell the kind from.
        #expect(october.points.isEmpty)
        #expect(!october.curve.isEmpty)
        #expect(october.reading(of: 10) == .reps(10))
    }

    @Test
    func labelsReadInTheReadersUnits() throws {
        squat.kind = .weight
        let session = try store.session(7)
        let entry = try #require((session.entries ?? []).sorted().first)
        entry.target = .weight(kilograms: 100, reps: 5, sets: 3)
        entry.status = .completed(date: session.startDate)

        let progression = try progression()

        // The rank is in kilograms, and the axis reads in whatever the reader measures in.
        #expect(progression.points.map(\.target.rank) == [100])
        #expect(progression.reading(of: 100) == .weight(kilograms: 100))
    }

    @Test
    func repsAreTheUnitToReadRepsBackIn() throws {
        try squatSession(7, reps: 10)

        #expect(try progression().reading(of: 10) == .reps(10))
    }
}

// MARK: - Active days

@MainActor
struct ActiveDaysTests {
    let store: TestStore

    let calendar = Calendar.berlin()

    init() throws {
        self.store = try TestStore()
    }

    func history(at now: Date, calendar: Calendar? = nil) -> History {
        History(.all, among: store.workout.sessions ?? [], at: now, calendar: calendar ?? self.calendar)
    }

    /// The twelve weeks up to the one `now` falls in.
    func activeDays(at now: Date, calendar: Calendar? = nil) -> ActiveDays {
        ActiveDays(history(at: now, calendar: calendar).weeks(12))
    }

    /// The cell the given day sits in, if the grid reaches back that far.
    func day(_ date: Date, in activeDays: ActiveDays) -> ActiveDays.Day? {
        activeDays.days.first { calendar.isDate($0.date, inSameDayAs: date) }
    }

    func trainedDays(in activeDays: ActiveDays) -> Int {
        activeDays.days.count { $0.sessionCount > 0 }
    }

    @Test
    func gridIsAsManyWeeksOfSevenDaysAsAskedFor() throws {
        let history = try history(at: calendar.date(16))

        #expect(ActiveDays(history.weeks(12)).days.count == 12 * 7)
        #expect(ActiveDays(history.weeks(4)).days.count == 4 * 7)
        #expect(trainedDays(in: ActiveDays(history.weeks(12))) == 0)
    }

    @Test(arguments: [0, -1])
    func gridOfNoWeeksIsEmpty(count: Int) throws {
        #expect(try ActiveDays(history(at: calendar.date(16)).weeks(count)).days.isEmpty)
    }

    @Test
    func gridEndsWithTheWeekItWasReadOn() throws {
        // Twelve weeks up to the week of Wednesday, Sep 16: from Monday, Jun 29, to Sunday, Sep 20.
        let days = try activeDays(at: calendar.date(16)).days

        #expect(try days.first?.date == calendar.date(29, month: 6, hour: 0))
        #expect(try days.last?.date == calendar.date(20, hour: 0))
    }

    @Test
    func monthIsItsOwnDaysOnly() throws {
        try store.session(7)
        try store.session(1, month: 10)

        let september = try ActiveDays(history(at: calendar.date(16, month: 10)).month(containing: calendar.date(10)))

        // Read in October, September is still just its thirty days, and October's session stays off it.
        #expect(try september.days.first?.date == calendar.date(1, hour: 0))
        #expect(try september.days.last?.date == calendar.date(30, hour: 0))
        #expect(try day(calendar.date(1, month: 10), in: september) == nil)
        #expect(trainedDays(in: september) == 1)
    }

    @Test
    func monthStillAheadIsAllAhead() throws {
        try store.session(7)

        let october = try ActiveDays(history(at: calendar.date(16)).month(containing: calendar.date(10, month: 10)))

        // Every one of its days is there to lay out, but none has anything to show yet.
        #expect(october.days.count == 31)
        #expect(october.days.allSatisfy { $0.isAhead && $0.sessionCount == 0 })
    }

    @Test(arguments: [1, 2])
    func rowsStartOnTheCalendarsFirstWeekday(firstWeekday: Int) throws {
        let calendar = Calendar.berlin(firstWeekday: firstWeekday)
        let activeDays = try activeDays(at: calendar.date(16), calendar: calendar)

        #expect(activeDays.days.count.isMultiple(of: 7))
        #expect(try calendar.component(.weekday, from: #require(activeDays.days.first).date) == firstWeekday)
        // The rows stand for the weekdays in the same order, which is what the card labels them with.
        #expect(activeDays.weekdaySymbols.count == 7)
        #expect(activeDays.weekdaySymbols.first == calendar.veryShortWeekdaySymbols[firstWeekday - 1])
    }

    @Test
    func aDayCountsEverythingDoneOnIt() throws {
        try store.session(7, hour: 8)
        try store.session(7, hour: 18)
        try store.session(8)

        let activeDays = try activeDays(at: calendar.date(16))

        #expect(try day(calendar.date(7), in: activeDays)?.sessionCount == 2)
        #expect(try day(calendar.date(8), in: activeDays)?.sessionCount == 1)
        #expect(try day(calendar.date(9), in: activeDays)?.sessionCount == 0)
        #expect(trainedDays(in: activeDays) == 2)
    }

    @Test
    func daysAfterTodayAreAhead() throws {
        // Wednesday, so the rest of its week is still to come and stands for nothing.
        let activeDays = try activeDays(at: calendar.date(16))

        #expect(try day(calendar.date(16), in: activeDays)?.isAhead == false)
        #expect(try day(calendar.date(17), in: activeDays)?.isAhead == true)
        #expect(activeDays.days.suffix(7).count(where: \.isAhead) == 4)
        #expect(!activeDays.days.dropLast(7).contains { $0.isAhead })
    }

    @Test
    func daysBeforeTheFirstSessionHavePassedToo() throws {
        try store.session(9)

        let activeDays = try activeDays(at: calendar.date(16))

        // They were there to train on, so the grid fills up with them rather than leaving them out.
        #expect(try day(calendar.date(8), in: activeDays)?.isAhead == false)
        #expect(try day(calendar.date(8), in: activeDays)?.sessionCount == 0)
        #expect(try day(calendar.date(9), in: activeDays)?.sessionCount == 1)
    }

    @Test
    func daysAreTheOnesTheyWereRecordedOn() throws {
        // Sunday 23:00 in New York is already Monday in Berlin, but the user trained on Sunday.
        try store.session(13, hour: 23, zone: "America/New_York")

        let activeDays = try activeDays(at: calendar.date(16))

        #expect(try day(calendar.date(13), in: activeDays)?.sessionCount == 1)
        #expect(try day(calendar.date(14), in: activeDays)?.sessionCount == 0)
    }

    @Test
    func historyOlderThanTheGridIsNotOnIt() throws {
        // Twelve weeks up to the week of Sep 14 reach back to the week of Jun 29.
        try store.session(1, month: 2)
        try store.session(22, month: 6)
        try store.session(29, month: 6)

        let activeDays = try activeDays(at: calendar.date(16))

        #expect(try day(calendar.date(29, month: 6), in: activeDays)?.sessionCount == 1)
        #expect(try day(calendar.date(22, month: 6), in: activeDays) == nil)
        #expect(trainedDays(in: activeDays) == 1)
    }

    @Test
    func runningSessionsAreNotOnTheGrid() throws {
        let running = try store.startSession()
        running.startDate = try calendar.date(15)

        #expect(try trainedDays(in: activeDays(at: calendar.date(16))) == 0)
    }

    @Test
    func workoutCountsTheDaysItWasDoneOn() throws {
        try store.session(7, hour: 8)
        try store.session(7, hour: 18)

        let activeDays = try ActiveDays(History(.workout(store.workout), among: store.sessions, at: calendar.date(16), calendar: calendar).weeks(12))

        #expect(try day(calendar.date(7), in: activeDays)?.sessionCount == 2)
        #expect(trainedDays(in: activeDays) == 1)
    }

    @Test
    func exerciseCountsTheDaysItWasCompletedOn() throws {
        // The squat is completed on the seventh and skipped on the eighth.
        try store.session(7) { session in
            session.completeAndAdvance()
            session.skipAndAdvance()
        }
        try store.session(8) { $0.skipAndAdvance() }

        let squat = try #require((store.workout.entries ?? []).sorted().first?.exercise)
        let history = try History(.exercise(squat), among: store.sessions, at: calendar.date(16), calendar: calendar)
        let activeDays = ActiveDays(history.weeks(12))

        #expect(try day(calendar.date(7), in: activeDays)?.sessionCount == 1)
        #expect(try day(calendar.date(8), in: activeDays)?.sessionCount == 0)
        #expect(trainedDays(in: activeDays) == 1)
    }

    @Test
    func exerciseDoneTwiceCountsTheSessionOnce() throws {
        let squat = try #require((store.workout.entries ?? []).sorted().first?.exercise)
        store.workout.append(exercise: squat, target: .bodyweight(reps: 10, sets: 3))
        try store.session(7) { session in
            for _ in session.entries ?? [] {
                session.completeAndAdvance()
            }
        }

        let history = try History(.exercise(squat), among: store.sessions, at: calendar.date(16), calendar: calendar)

        #expect(try day(calendar.date(7), in: ActiveDays(history.weeks(12)))?.sessionCount == 1)
    }
}

// MARK: - Categories

@MainActor
struct CategoriesTests {
    let store: TestStore

    let exercises: [Exercise]

    let calendar = Calendar.berlin()

    init() throws {
        self.store = try TestStore()
        self.exercises = (store.workout.entries ?? []).sorted().compactMap(\.exercise)
    }

    func history() throws -> History {
        try History(.workout(store.workout), among: store.sessions, at: calendar.date(16, month: 10), calendar: calendar)
    }

    /// What was completed over everything on record.
    func completed() throws -> Categories {
        try Categories(history().allTime)
    }

    /// Gives the workout's exercises a category each, in workout order.
    func categorize(_ categories: [Set<Exercise.Category>]) {
        for (exercise, categories) in zip(exercises, categories) {
            exercise.categories = categories
        }
    }

    /// A session with every exercise of the workout completed.
    func completeAll(_ day: Int) throws {
        try store.session(day) { session in
            session.completeAndAdvance()
            session.completeAndAdvance()
            session.completeAndAdvance()
        }
    }

    @Test
    func withoutCategoriesThereIsNothingToShow() throws {
        categorize([[], [], []])
        try completeAll(7)

        #expect(try completed().shares.isEmpty)
    }

    @Test
    func anExerciseCountsInEachOfItsCategories() throws {
        categorize([[.legs, .back], [.chest], []])
        try completeAll(7)

        let categories = try completed()
        let third = 1.0 / 3.0

        // Three tallies over three categories, which tie and stay in the order they are declared in.
        #expect(categories.shares.map(\.category) == [.legs, .chest, .back])
        #expect(categories.shares.map(\.count) == [1, 1, 1])
        #expect(categories.shares.map(\.fraction) == [third, third, third])
    }

    @Test
    func theMostTrainedCategoryComesFirst() throws {
        categorize([[.legs], [.legs, .chest], [.legs]])
        try completeAll(7)

        let categories = try completed()

        #expect(categories.shares.map(\.category) == [.legs, .chest])
        #expect(categories.shares.map(\.count) == [3, 1])
        #expect(categories.shares.map(\.fraction) == [0.75, 0.25])
    }

    @Test
    func onlyTheExercisesThatWereDoneCountAndNotWhatTheWorkoutPlans() throws {
        categorize([[.legs], [.chest], [.back]])
        try store.session(7) { session in
            session.completeAndAdvance()
            session.skipAndAdvance()
        }

        // The bench press was skipped and the deadlift left pending, so neither was trained.
        #expect(try completed().shares.map(\.category) == [.legs])
        #expect(try completed().shares.map(\.fraction) == [1])
    }

    @Test
    func eachTimeAnExerciseWasDoneCounts() throws {
        categorize([[.legs], [.legs, .chest], []])

        for day in [7, 8] {
            try store.session(day) { session in
                session.completeAndAdvance()
                session.completeAndAdvance()
            }
        }

        // Two squats and two bench presses, and the bench press trains two categories: six tallies in all.
        #expect(try completed().shares.map(\.category) == [.legs, .chest])
        #expect(try completed().shares.map(\.count) == [4, 2])
    }

    @Test
    func onlySessionsWithinTheWindowCount() throws {
        categorize([[.legs], [], []])
        try store.session(31, month: 8) { $0.completeAndAdvance() }

        #expect(try Categories(history().month(containing: calendar.date(10))).shares.isEmpty)
        #expect(try completed().shares.map(\.category) == [.legs])
    }

    @Test
    func runningSessionsAreNotCounted() throws {
        categorize([[.legs], [], []])
        let running = try store.startSession()
        running.completeAndAdvance()

        #expect(try completed().shares.isEmpty)
    }
}

// MARK: - Workout entry

@MainActor
struct WorkoutEntryStatisticsTests {
    let store: TestStore

    let squat: Exercise

    let calendar = Calendar.berlin()

    init() throws {
        self.store = try TestStore()
        self.squat = try #require((store.workout.entries ?? []).sorted().first?.exercise)
    }

    func history(_ subject: History.Subject) throws -> History {
        try History(subject, among: store.sessions, at: calendar.date(16, month: 10), calendar: calendar)
    }

    /// A finished session of `workout` on the given day, with the given slot completed at the given reps.
    @discardableResult
    func complete(_ slot: WorkoutEntry, of workout: Workout, day: Int, reps: Int) throws -> Session {
        let session = try #require(workout.startSession())
        let entry = try #require((session.entries ?? []).first { $0.workoutEntry === slot })
        session.startDate = try calendar.date(day, hour: 8)
        session.endDate = session.startDate.addingTimeInterval(3600)
        entry.target = .bodyweight(reps: reps, sets: 3)
        entry.status = .completed(date: session.startDate)
        return session
    }

    @Test
    func slotLeavesOutTheSameExerciseInAnotherWorkout() throws {
        let warmups = Workout(name: "Warmup", pictogram: .workout, schedule: .inactive, entries: [])
        store.context.insert(warmups)
        warmups.append(exercise: squat, target: .bodyweight(reps: 5, sets: 1))
        let warmupSlot = try #require((warmups.entries ?? []).sorted().first)
        let mainSlot = try #require((store.workout.entries ?? []).sorted().first)

        try complete(mainSlot, of: store.workout, day: 7, reps: 12)
        try complete(warmupSlot, of: warmups, day: 8, reps: 20)

        let main = try history(.entry(mainSlot)).allTime
        let exercise = try history(.exercise(squat)).allTime

        #expect(main.completionCount == 1)
        #expect(main.personalBest?.bodyweightTarget?.reps == 12)
        // The exercise on its own counts both.
        #expect(exercise.completionCount == 2)
        #expect(exercise.personalBest?.bodyweightTarget?.reps == 20)
    }

    @Test
    func twoSlotsOfOneWorkoutStayApart() throws {
        store.workout.append(exercise: squat, target: .bodyweight(reps: 5, sets: 1))
        let slots = (store.workout.entries ?? []).filter { $0.exercise === squat }.sorted()
        let first = try #require(slots.first)
        let second = try #require(slots.last)

        // The first slot is completed, the second skipped in the same session.
        let session = try complete(first, of: store.workout, day: 7, reps: 12)
        let skipped = try #require((session.entries ?? []).first { $0.workoutEntry === second })
        skipped.status = .skipped(date: session.startDate)

        #expect(slots.count == 2)
        #expect(try history(.entry(first)).allTime.completionCount == 1)
        #expect(try history(.entry(second)).allTime.completionCount == 0)
        #expect(try history(.entry(second)).allTime.completionRate == 0)
        #expect(try history(.entry(second)).allTime.lastCompletion?.date == nil)
    }
}
