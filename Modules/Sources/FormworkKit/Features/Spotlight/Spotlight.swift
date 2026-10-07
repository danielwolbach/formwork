//
//  Spotlight.swift
//  FormworkModules
//
//  Created by Daniel Wolbach on 07.10.26.
//

import CoreSpotlight

@MainActor
public enum Spotlight {
    private static var pending: Task<Void, Never>?

    public static func sync(_ workouts: [Workout]) {
        let entities = workouts.filter { !$0.isArchived }.map(WorkoutEntity.init)
        let previous = pending

        pending = Task {
            await previous?.value

            do {
                let index = CSSearchableIndex.default()
                try await index.deleteAllSearchableItems()
                try await index.indexAppEntities(entities)
            } catch {
                // TODO: Log error.
            }
        }
    }
}
