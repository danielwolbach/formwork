//
//  ModelContainerInstance.swift
//  GymTrack
//

import SwiftData

@MainActor
enum ModelContainerInstance {
    static let shared = LaunchConfiguration.sampleData
        ? SampleData.container
        : persistent

    private static let persistent: ModelContainer = {
        do {
            return try ModelContainer(
                for:
                Exercise.self,
                Workout.self,
                WorkoutEntry.self,
                Session.self,
                SessionEntry.self
            )
        } catch {
            fatalError("Failed to create the model container: \(error)")
        }
    }()
}
