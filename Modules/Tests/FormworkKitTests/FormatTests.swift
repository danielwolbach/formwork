//
//  FormatTests.swift
//  FormworkKitTests
//
//  Created by Daniel Wolbach on 29.09.26.
//

@testable import FormworkKit
import Foundation
import Testing

struct FormatTests {
    @Test
    func dotListSkipsEmptyParts() {
        #expect(["80 kg", "", "3 × 8"].formatted(.dotList) == "80 kg · 3 × 8")
    }

    @Test(arguments: [(1, "1 exercise"), (5, "5 exercises")])
    func exerciseCountAgreesWithTheNumber(count: Int, expected: String) {
        #expect(count.formatted(.exerciseCount) == expected)
    }

    @Test
    func weightTargetShowsLoadSetsAndReps() {
        let target = ExerciseTarget.weight(kilograms: 100, reps: 8, sets: 3)

        #expect(target.formatted(.exerciseTarget(system: .metric)) == "100 kg · 3 × 8")
    }

    @Test
    func weightTargetReadsInTheGivenSystem() {
        let target = ExerciseTarget.weight(kilograms: 100, reps: 8, sets: 3)

        #expect(target.formatted(.exerciseTarget(system: .metric)).contains(" kg"))
        #expect(target.formatted(.exerciseTarget(system: .imperial)).contains(" lb"))
    }

    @Test(arguments: [
        ExerciseTarget.duration(seconds: 10 * 60, sets: 1),
        ExerciseTarget.distance(meters: 5 * 1000, sets: 1),
    ])
    func singleSetShowsOnlyTheRank(target: ExerciseTarget) {
        let rank = RankFormat(kind: target.exerciseKind, system: .metric).format(target.rank)

        #expect(target.formatted(.exerciseTarget(system: .metric)) == rank)
    }

    @Test(arguments: [
        ExerciseTarget.duration(seconds: 10 * 60, sets: 3),
        ExerciseTarget.distance(meters: 5 * 1000, sets: 3),
    ])
    func severalSetsCountTheSets(target: ExerciseTarget) {
        let rank = RankFormat(kind: target.exerciseKind, system: .metric).format(target.rank)
        let formatted = target.formatted(.exerciseTarget(system: .metric))

        #expect(formatted != rank)
        #expect(formatted.contains(rank))
    }

    @Test
    func exerciseListsCategoriesInCatalogOrder() {
        let exercise = Exercise(name: "Deadlift", kind: .weight, categories: [.back, .legs])

        #expect(exercise.categories.formatted(.exerciseCategories) == [Exercise.Category.legs.title, Exercise.Category.back.title].formatted(.list(type: .and, width: .narrow)))
    }

    @MainActor
    @Test
    func sessionIsDatedByTheClockItWasRecordedOn() throws {
        let store = try TestStore()
        let session = try store.session(7, hour: 8, zone: "America/New_York")
        var local = Calendar.current
        local.timeZone = try #require(TimeZone(identifier: "America/New_York"))
        let inNewYork = Date.FormatStyle(date: .numeric, time: .shortened, calendar: local, timeZone: local.timeZone)

        // 08:00 in New York is 14:00 in Berlin, but the user remembers starting at 08:00.
        #expect(session.startDate.formatted(session.wallClockTime(date: .numeric)) == session.startDate.formatted(inNewYork))
    }

    @MainActor
    @Test
    func wallClockTimeIsTheClockItWasRecordedOn() throws {
        let store = try TestStore()
        let session = try store.session(7, hour: 8, zone: "America/New_York")
        var local = Calendar.current
        local.timeZone = try #require(TimeZone(identifier: "America/New_York"))

        #expect(session.startDate.formatted(session.wallClockTime()) == session.startDate.formatted(local.formatStyle(time: .shortened)))
    }

    @MainActor
    @Test
    func workoutWithoutRecentSessionsShowsOnlyItsExercises() throws {
        let store = try TestStore()

        #expect(try store.workout.formatted(WorkoutDetailsFormat(at: Calendar.berlin().date(10))) == "3 exercises")
    }

    @MainActor
    @Test
    func workoutAddsHowLongItTypicallyTakes() throws {
        let store = try TestStore()
        try store.session(7, minutes: 45)

        let expected = ["3 exercises", DurationFormat().format(45 * 60)].formatted(.dotList)
        #expect(try store.workout.formatted(WorkoutDetailsFormat(at: Calendar.berlin().date(10))) == expected)
    }
}
