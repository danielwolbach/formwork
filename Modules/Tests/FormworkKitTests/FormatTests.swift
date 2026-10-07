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
    @Test(arguments: [
        (80.0, Exercise.Kind?.some(.weight), Reading.weight(kilograms: 80)),
        (12, .bodyweight, .reps(12)),
        (600, .duration, .duration(seconds: 600)),
        (5000, .distance, .distance(meters: 5000)),
        (3, nil, .count(3)),
    ])
    func rankReadsByTheKindOfExercise(rank: Double, kind: Exercise.Kind?, expected: Reading) {
        #expect(Reading(rank: rank, of: kind) == expected)
    }

    @Test
    func imperialReadersReadPoundsAndMiles() {
        #expect(Reading.weight(kilograms: 100).formatted(.reading(units: Units(weight: .imperial, distance: .metric))).hasSuffix(" lb"))
        #expect(Reading.distance(meters: 5000).formatted(.reading(units: Units(weight: .metric, distance: .imperial))).hasSuffix(" mi"))
    }

    @Test(arguments: [
        (Reading.weight(kilograms: 100), "kg"),
        (.distance(meters: 5000), "km"),
        (.distance(meters: 400), "m"),
    ])
    func metricReadingsUseMetricUnits(reading: Reading, symbol: String) {
        #expect(reading.formatted(.reading(units: .metric)).hasSuffix(" \(symbol)"))
    }

    @Test(arguments: [(1, "1 rep"), (12, "12 reps")])
    func repsAreTheirOwnUnit(reps: Int, expected: String) {
        #expect(Reading.reps(reps).formatted(.reading(units: .metric)) == expected)
    }

    @Test
    func shortDurationsReadInSeconds() {
        #expect(Reading.duration(seconds: 40).formatted(.reading(units: .metric)) == Duration.seconds(40).formatted(.units(allowed: [.seconds], width: .abbreviated)))
    }

    @Test
    func dotListSkipsEmptyParts() {
        #expect(["80 kg", "", "3 × 8"].formatted(.dotList) == "80 kg · 3 × 8")
    }

    @Test(arguments: [(1, "1 Exercise"), (5, "5 Exercises")])
    func exerciseCountAgreesWithTheNumber(count: Int, expected: String) {
        #expect(count.formatted(.exerciseCount) == expected)
    }

    @Test
    func weightTargetShowsLoadSetsAndReps() {
        let target = ExerciseTarget.weight(kilograms: 100, reps: 8, sets: 3)

        #expect(target.formatted(.exerciseTarget(units: .metric)) == "100 kg · 3 × 8")
    }

    @Test(arguments: [
        (Units.System.metric, "10 kg", "1 km"),
        (Units.System.imperial, "20 lb", "1 mi"),
    ])
    func initialTargetsAreRoundInTheReadersUnits(system: Units.System, load: String, distance: String) {
        let units = Units(weight: system, distance: system)

        #expect(Reading(rank: ExerciseTarget.initial(for: .weight, in: units).rank, of: .weight).formatted(.reading(units: units)) == load)
        #expect(Reading(rank: ExerciseTarget.initial(for: .distance, in: units).rank, of: .distance).formatted(.reading(units: units)) == distance)
    }

    @Test
    func weightTargetReadsInTheGivenSystem() {
        let target = ExerciseTarget.weight(kilograms: 100, reps: 8, sets: 3)

        #expect(target.formatted(.exerciseTarget(units: .metric)).contains(" kg"))
        #expect(target.formatted(.exerciseTarget(units: Units(weight: .imperial, distance: .metric))).contains(" lb"))
    }

    @Test(arguments: [
        ExerciseTarget.duration(seconds: 10 * 60, sets: 1),
        ExerciseTarget.distance(meters: 5 * 1000, sets: 1),
    ])
    func singleSetShowsOnlyTheRank(target: ExerciseTarget) {
        let rank = Reading(rank: target.rank, of: target.exerciseKind).formatted(.reading(units: .metric))

        #expect(target.formatted(.exerciseTarget(units: .metric)) == rank)
    }

    @Test(arguments: [
        ExerciseTarget.duration(seconds: 10 * 60, sets: 3),
        ExerciseTarget.distance(meters: 5 * 1000, sets: 3),
    ])
    func severalSetsCountTheSets(target: ExerciseTarget) {
        let rank = Reading(rank: target.rank, of: target.exerciseKind).formatted(.reading(units: .metric))
        let formatted = target.formatted(.exerciseTarget(units: .metric))

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

        #expect(try store.workout.formatted(WorkoutDetailsFormat(at: Calendar.berlin().date(10))) == "3 Exercises")
    }

    @MainActor
    @Test
    func workoutAddsHowLongItTypicallyTakes() throws {
        let store = try TestStore()
        try store.session(7, minutes: 45)

        let expected = ["3 Exercises", Reading.duration(seconds: 45 * 60).formatted(.reading(units: .metric))].formatted(.dotList)
        #expect(try store.workout.formatted(WorkoutDetailsFormat(at: Calendar.berlin().date(10))) == expected)
    }

    @MainActor
    @Test
    func sessionProgressCountsWhatIsPending() throws {
        let store = try TestStore()
        let session = try store.startSession()

        #expect(session.formatted(SessionProgressFormat(at: session.startDate)) == "3 Pending")
    }

    @MainActor
    @Test
    func sessionProgressEstimatesWhenItFinishes() throws {
        let store = try TestStore()
        try store.session(7, minutes: 45)
        let now = try Calendar.berlin().date(10)
        let session = try store.startSession()
        session.startDate = now.addingTimeInterval(-30 * 60)

        let finish = "→ " + session.startDate.addingTimeInterval(45 * 60).formatted(Calendar.current.formatStyle(time: .shortened))
        #expect(session.formatted(SessionProgressFormat(at: now)) == "3 Pending \(finish)")
    }

    @MainActor
    @Test
    func sessionProgressLeavesOutAFinishThatHasPassed() throws {
        let store = try TestStore()
        try store.session(7, minutes: 45)
        let now = try Calendar.berlin().date(10)
        let session = try store.startSession()
        session.startDate = now.addingTimeInterval(-60 * 60)

        #expect(session.formatted(SessionProgressFormat(at: now)) == "3 Pending")
    }
}
