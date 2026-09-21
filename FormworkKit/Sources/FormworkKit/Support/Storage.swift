//
//  Storage.swift
//  Formwork
//
//  Created by Daniel Wolbach on 06.09.26.
//

import Foundation
import SwiftData

@MainActor
public enum Storage {
    public static let schema = Schema(versionedSchema: CurrentSchema.self)

    public static let container: ModelContainer = if ProcessInfo.processInfo.arguments.contains("--sample-data") {
        Samples.container
    } else {
        try unwrap(
            ModelContainer(for: schema, migrationPlan: Migrations.self, configurations: [ModelConfiguration(schema: schema)]),
            "Failed to initialize storage"
        )
    }

    public static func deleteEverything(in modelContext: ModelContext) {
        do {
            for session in try modelContext.fetch(FetchDescriptor<Session>()) {
                modelContext.delete(session)
            }

            for workout in try modelContext.fetch(FetchDescriptor<Workout>()) {
                modelContext.delete(workout)
            }

            for exercise in try modelContext.fetch(FetchDescriptor<Exercise>()) {
                modelContext.delete(exercise)
            }
        } catch {
            // TODO: Log error
        }
    }
}

private func unwrap<T>(_ expression: @autoclosure () throws -> T, _ message: String) -> T {
    do {
        return try expression()
    } catch {
        fatalError("\(message): \(error)")
    }
}
