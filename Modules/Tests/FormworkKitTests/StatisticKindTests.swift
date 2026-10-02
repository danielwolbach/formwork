//
//  StatisticKindTests.swift
//  FormworkKitTests
//
//  Created by Daniel Wolbach on 02.10.26.
//

@testable import FormworkKit
import Foundation
import Testing

@MainActor
struct StatisticKindTests {
    @Test
    func onlyChartsAreCharts() {
        let charts = StatisticKind.allCases.filter(\.isChart)

        #expect(Set(charts) == [.activeDays, .categories, .progression])
    }

    @Test
    func weightStatisticsNeedAWeightExercise() throws {
        let store = try TestStore()
        let entry = try #require(store.workout.entries.first)
        let exercise = try #require(entry.exercise)

        #expect(!History.Subject.exercise(exercise).statistics.contains(.oneRepMax))
        #expect(!History.Subject.entry(entry).statistics.contains(.oneRepMax))

        exercise.kind = .weight

        #expect(History.Subject.exercise(exercise).statistics.contains(.oneRepMax))
        #expect(History.Subject.entry(entry).statistics.contains(.oneRepMax))
    }

    @Test
    func subjectsListEachStatisticOnce() throws {
        let store = try TestStore()
        let entry = try #require(store.workout.entries.first)
        let exercise = try #require(entry.exercise)
        exercise.kind = .weight

        let subjects: [History.Subject] = [.all, .workout(store.workout), .exercise(exercise), .entry(entry)]

        for subject in subjects {
            #expect(Set(subject.statistics).count == subject.statistics.count)
        }
    }

    @Test
    func everyKindBelongsToASubject() throws {
        let store = try TestStore()
        let exercise = try #require(store.workout.entries.first?.exercise)
        exercise.kind = .weight

        let subjects: [History.Subject] = [.all, .workout(store.workout), .exercise(exercise)]

        #expect(Set(subjects.flatMap(\.statistics)) == Set(StatisticKind.allCases))
    }

    @Test
    func summariesReadRecordsOverAllTimeAndHabitsOverRecentDays() throws {
        let store = try TestStore()
        let calendar = Calendar.berlin()
        try store.session(1, month: 6)

        let history = try History(.all, among: store.sessions, at: calendar.date(16), calendar: calendar)

        #expect(reading(of: .lastCompleted, in: history) != nil)
        #expect(reading(of: .typicalStartTime, in: history) == nil)
        #expect(reading(of: .favoriteWorkout, in: history) == nil)
    }

    func reading(of kind: StatisticKind, in history: History) -> Reading? {
        guard case let .reading(reading, _) = kind.summary(of: history) else {
            return nil
        }

        return reading
    }
}
