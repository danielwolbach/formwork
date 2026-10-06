//
//  PresentationTests.swift
//  FormworkKitTests
//
//  Created by Daniel Wolbach on 18.09.26.
//

@testable import FormworkKit
import Foundation
import Testing

/// Titles and pictograms, which models provide for any view to show.
struct PresentationTests {
    @Test(arguments: [
        (ExerciseTarget.weight(kilograms: 10, reps: 10, sets: 3), Exercise.Kind.weight),
        (ExerciseTarget.bodyweight(reps: 10, sets: 3), Exercise.Kind.bodyweight),
        (ExerciseTarget.duration(seconds: 10 * 60), Exercise.Kind.duration),
        (ExerciseTarget.distance(meters: 1 * 1000), Exercise.Kind.distance),
    ])
    func targetDisplaysItsKind(target: ExerciseTarget, kind: Exercise.Kind) {
        #expect(target.exerciseKind == kind)
        #expect(target.title == kind.title)
        #expect(target.pictogram == kind.pictogram)
    }

    @MainActor
    @Test
    func entryWithoutExerciseHasFallbackTitle() throws {
        let store = try TestStore()
        let entry = try #require((store.workout.entries ?? []).first)

        entry.exercise = nil

        #expect(entry.title == String(localized: .exerciseDeletedTitle))
        #expect(entry.pictogram == .unknown)
    }
}
