//
//  StatisticTests.swift
//  FormworkKitTests
//
//  Created by Daniel Wolbach on 02.10.26.
//

@testable import FormworkKit
import Foundation
import Testing

@MainActor
struct StatisticTests {
    let store: TestStore

    let calendar = Calendar.berlin()

    init() throws {
        self.store = try TestStore()
    }

    func history(_ subject: History.Subject) throws -> History {
        try History(subject, among: store.sessions, at: calendar.date(16), calendar: calendar)
    }

    @Test
    func onlyChartsAreCharts() {
        let charts = Statistic.allCases.filter(\.isChart)

        #expect(Set(charts) == [.activeDays, .categories, .progression])
    }

    @Test
    func weightStatisticsNeedAWeightExercise() throws {
        let entry = try #require((store.workout.entries ?? []).first)
        let exercise = try #require(entry.exercise)

        #expect(!History.Subject.exercise(exercise).statistics.contains(.oneRepMax))
        #expect(!History.Subject.entry(entry).statistics.contains(.oneRepMax))

        exercise.kind = .weight

        #expect(History.Subject.exercise(exercise).statistics.contains(.oneRepMax))
        #expect(History.Subject.entry(entry).statistics.contains(.oneRepMax))
    }

    @Test
    func subjectsListEachStatisticOnce() throws {
        let entry = try #require((store.workout.entries ?? []).first)
        let exercise = try #require(entry.exercise)
        exercise.kind = .weight

        let subjects: [History.Subject] = [.all, .workout(store.workout), .exercise(exercise), .entry(entry)]

        for subject in subjects {
            #expect(Set(subject.statistics).count == subject.statistics.count)
        }
    }

    @Test
    func everyStatisticBelongsToASubject() throws {
        let exercise = try #require((store.workout.entries ?? []).first?.exercise)
        exercise.kind = .weight

        let subjects: [History.Subject] = [.all, .workout(store.workout), .exercise(exercise)]

        #expect(Set(subjects.flatMap(\.statistics)) == Set(Statistic.allCases))
    }

    @Test
    func everyStatisticReadsOnACardUnlessItsAChart() throws {
        let entry = try #require((store.workout.entries ?? []).sorted().first)
        let exercise = try #require(entry.exercise)
        exercise.kind = .weight

        for day in [1, 8, 15] {
            try store.session(day, month: 8) { $0.completeAndAdvance() }
        }

        let subjects: [History.Subject] = [.all, .workout(store.workout), .exercise(exercise), .entry(entry)]

        for subject in subjects {
            let history = try history(subject)

            for statistic in subject.statistics where statistic.isChart {
                #expect(statistic.reading(in: history) == nil, "\(statistic)")
            }
        }
    }

    @Test
    func cardsReadRecordsOverAllTimeAndHabitsOverRecentDays() throws {
        try store.session(1, month: 6)

        let history = try history(.all)

        #expect(Statistic.lastCompleted.reading(in: history) != nil)
        #expect(Statistic.typicalStartTime.reading(in: history) == nil)
        #expect(Statistic.favoriteWorkout.reading(in: history) == nil)
    }

    @Test
    func comparingFormulaShowsBeforeEvenWithoutHistory() throws {
        try store.session(7)

        let comparison = try history(.workout(store.workout)).comparison(.typical(.duration), tolerance: 0.05)

        #expect(comparison == Comparison(current: .duration(seconds: 3600), typical: nil, direction: nil))
    }

    @Test
    func formulaWithoutToleranceDoesNotCompare() throws {
        for (day, month) in [(10, 7), (20, 7), (30, 7), (7, 9)] {
            try store.session(day, month: month)
        }

        let comparison = try history(.workout(store.workout)).comparison(.count, tolerance: nil)

        #expect(comparison == Comparison(current: .count(1), typical: nil, direction: nil))
    }

    @Test
    func nameFormulasReadWithoutComparing() throws {
        try store.session(1, month: 8)

        let history = try history(.all)

        #expect(history.comparison(.mostFrequent(.workout), tolerance: nil).current == nil)
        #expect(history.allTime.reading(.mostFrequent(.workout)) == .name("Full Body"))
    }

    @Test
    func seriesChartsEachSessionOnItsOwnEvenOnTheSameDay() throws {
        try store.session(7, hour: 8, minutes: 60)
        try store.session(7, hour: 18, minutes: 30)
        try store.session(9, minutes: 45)

        let series = try #require(history(.workout(store.workout)).series(.typical(.duration)))

        #expect(series.values == [3600, 1800, 2700])
    }

    @Test
    func seriesCoversTheDaysTheTrendCompares() throws {
        // 112 days before September 16 reach back to May 28.
        try store.session(27, month: 5)
        try store.session(28, month: 5)
        try store.session(7)

        let series = try #require(history(.workout(store.workout)).series(.typical(.duration)))

        #expect(try series.points.map(\.date) == [calendar.date(28, month: 5, hour: 8), calendar.date(7, hour: 8)])
    }

    @Test
    func formulasWithoutAValueOfEachSessionHaveNoSeries() throws {
        try store.session(7)

        let history = try history(.workout(store.workout))

        #expect(history.series(.count) == nil)
        #expect(history.series(.typical(.startTime)) == nil)
    }

    @Test
    func streakKnowsTheCurrentAndTheLongest() throws {
        try store.session(7)

        let streak = try history(.all).allTime.streak

        #expect(streak.weeks == 1)
        #expect(streak.longest == 1)
    }

    @Test
    func progressionComparesTypicalBestsAndPersonalBestIsOverall() throws {
        try store.session(7) { $0.completeAndAdvance() }
        let squat = try #require((store.workout.entries ?? []).sorted().first?.exercise)

        let history = try history(.exercise(squat))

        #expect(Progression.comparison(in: history) == Comparison(current: .reps(10), typical: nil, direction: nil))
        #expect(history.allTime.reading(.maximum(.best)) == .reps(10))
        #expect(Progression(history.year(2026)).points.map(\.target.rank) == [10])
    }

    @Test
    func yearIsTheWholeYearAskedFor() throws {
        try store.session(7)

        let history = try history(.all)

        #expect(history.years == 2026 ... 2026)
        #expect(ActiveDays(history.year(2026)).days.count == 365)
    }

    @Test
    func monthlySeriesHasABarForEveryMonthOnRecord() throws {
        try store.session(7)

        let series = try #require(history(.workout(store.workout)).monthly(.count, in: 2026))

        #expect(series.points.map(\.value) == [1])
        #expect(series.reading(of: 1) == .count(1))
    }

    @Test
    func monthlySeriesNeedsANumber() throws {
        try store.session(7)

        #expect(try history(.all).monthly(.latest, in: 2026) == nil)
    }
}
