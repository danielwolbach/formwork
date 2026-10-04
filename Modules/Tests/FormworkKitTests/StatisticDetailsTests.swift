//
//  StatisticDetailsTests.swift
//  FormworkKitTests
//
//  Created by Daniel Wolbach on 02.10.26.
//

@testable import FormworkKit
import Foundation
import Testing

@MainActor
struct StatisticDetailsTests {
    let store: TestStore

    let calendar = Calendar.berlin()

    init() throws {
        self.store = try TestStore()
    }

    func history(_ subject: History.Subject) throws -> History {
        try History(subject, among: store.sessions, at: calendar.date(16), calendar: calendar)
    }

    @Test
    func metricThatComparesShowsBeforeEvenWithoutHistory() throws {
        try store.session(7)

        let details = try StatisticKind.typicalDuration.details(of: history(.workout(store.workout)))

        #expect(details.values == [.trend(recent: .duration(seconds: 3600), before: nil, direction: nil), .overall(.duration(seconds: 3600))])
    }

    @Test
    func metricThatNeverComparesShowsItsRecentValueAlone() throws {
        try store.session(7)

        let details = try StatisticKind.completions.details(of: history(.workout(store.workout)))

        #expect(details.values == [.recent(.count(1)), .overall(.count(1))])
    }

    @Test
    func indicatorShowsRecentAndOverall() throws {
        try store.session(1, month: 8)

        let details = try StatisticKind.favoriteWorkout.details(of: history(.all))

        #expect(details.values == [.recent(nil), .overall(.name("Full Body"))])
    }

    @Test
    func streakShowsTheCurrentAndTheLongest() throws {
        try store.session(7)

        let details = try StatisticKind.weekStreak.details(of: history(.all))

        #expect(details.values == [.named(StatisticKind.weekStreak.definition.title, .count(1)), .named(String(localized: .statisticLongestWeekStreakTitle), .count(1))])
        #expect(details.yearly == nil)
    }

    @Test
    func progressionComparesTypicalBestsAndShowsThePersonalBestOverall() throws {
        try store.session(7) { $0.completeAndAdvance() }
        let squat = try #require(store.workout.entries.sorted().first?.exercise)

        let details = try StatisticKind.progression.details(of: history(.exercise(squat)))
        let chart = try #require(details.yearly?.chart(2026))

        #expect(details.values == [.trend(recent: .reps(10), before: nil, direction: nil), .overall(.reps(10))])

        guard case let .progression(progression) = chart else {
            Issue.record("Expected the progression chart, got \(chart).")
            return
        }

        #expect(progression.points.map(\.target.rank) == [10])
    }

    @Test
    func yearChartIsTheYearAskedFor() throws {
        try store.session(7)

        let history = try history(.all)
        let yearly = try #require(StatisticKind.activeDays.details(of: history).yearly)

        #expect(yearly.years == history.years)

        guard case let .activeDays(activeDays) = yearly.chart(2026) else {
            Issue.record("Expected the active days chart.")
            return
        }

        #expect(activeDays.days.count == 365)
    }

    @Test
    func monthlyChartHasABarForEveryMonthOnRecord() throws {
        try store.session(7)

        let yearly = try #require(StatisticKind.completions.details(of: history(.workout(store.workout))).yearly)

        guard case let .monthly(series, reading) = yearly.chart(2026) else {
            Issue.record("Expected the monthly chart.")
            return
        }

        #expect(series.bars.map(\.value) == [1])
        #expect(reading(1) == .count(1))
    }
}
