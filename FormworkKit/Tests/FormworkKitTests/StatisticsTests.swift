//
//  StatisticsTests.swift
//  FormworkKitTests
//
//  Created by Daniel Wolbach on 18.09.26.
//

@testable import FormworkKit
import Foundation
import Testing

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

@MainActor
struct ExerciseStatisticsTests {
    let store: TestStore
    let squat: Exercise

    init() throws {
        self.store = try TestStore()
        self.squat = try #require(store.workout.entries.sorted().first?.exercise)
    }

    @Test func exerciseWithoutSessionsHasNoValues() {
        let statistics = squat.statistics

        #expect(statistics.lastCompleted.value == nil)
        #expect(statistics.completionRate.value == nil)
        #expect(statistics.personalBest.value == nil)
        #expect(statistics.completions.value == 0)
        #expect(statistics.completions.subtitle == "0")
    }

    @Test func onlyFinishedSessionsCount() throws {
        let finished = try store.startSession()
        finished.completeAndAdvance()
        finished.finish()

        let running = try store.startSession()
        running.skipAndAdvance()

        let statistics = squat.statistics

        #expect(statistics.completions.value == 1)
        #expect(statistics.completionRate.value == 1)
        #expect(statistics.lastCompleted.subtitle != nil)
    }

    @Test func personalBestIgnoresTargetsOfAnotherType() throws {
        let session = try store.startSession()
        session.completeAndAdvance()
        session.finish()

        #expect(squat.statistics.personalBest.value?.bodyweightTarget == .init(sets: 3, reps: 10))

        squat.type = .weight

        #expect(squat.statistics.personalBest.value == nil)
    }
}

@MainActor
struct WorkoutStatisticsTests {
    @Test func countsFinishedSessionsAndMostSkippedExercise() throws {
        let store = try TestStore()

        for _ in 0 ..< 2 {
            let session = try store.startSession()
            session.completeAndAdvance()
            session.skipAndAdvance()
            session.finish()
        }

        _ = try store.startSession()

        let statistics = store.workout.statistics

        #expect(statistics.completions.value == 2)
        #expect(statistics.mostSkippedExercise.subtitle == "Bench Press")
        #expect(statistics.typicalDuration.subtitle != nil)
        #expect(statistics.typicalStartTime.subtitle != nil)
    }

    @Test func completionRateCoversEveryExerciseOfFinishedSessions() throws {
        let store = try TestStore()

        #expect(store.workout.statistics.completionRate.value == nil)

        let complete = try store.startSession()
        complete.completeAndAdvance()
        complete.completeAndAdvance()
        complete.completeAndAdvance()
        complete.finish()

        let partial = try store.startSession()
        partial.completeAndAdvance()
        partial.skipAndAdvance()
        partial.finish()

        let running = try store.startSession()
        running.skipAndAdvance()

        // 3 of 3, then 1 of 3 with one skipped and one left pending. The running session doesn't count.
        #expect(store.workout.statistics.completionRate.value == 4.0 / 6.0)
    }
}
