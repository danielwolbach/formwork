//
//  Storage.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 06.09.26.
//

import Foundation
import OSLog
import SwiftData

@MainActor
public enum Storage {
    public static let schema = Schema(versionedSchema: CurrentSchema.self)

    public static let container: ModelContainer = {
        if ProcessInfo.processInfo.arguments.contains("--sample-data") {
            return Samples.container
        }

        do {
            return try ModelContainer(for: schema, migrationPlan: Migrations.self, configurations: [ModelConfiguration(schema: schema, groupContainer: .identifier(AppGroup.identifier))])
        } catch {
            fatalError("Failed to initialize storage: \(error)")
        }
    }()

    public static func deleteEverything(in modelContext: ModelContext) {
        do {
            for session in try modelContext.fetch(FetchDescriptor<Session>()) {
                modelContext.delete(session)
                Health.delete(session)
            }

            for workout in try modelContext.fetch(FetchDescriptor<Workout>()) {
                modelContext.delete(workout)
            }

            for exercise in try modelContext.fetch(FetchDescriptor<Exercise>()) {
                modelContext.delete(exercise)
            }

            Logger.storage.info("Deleted everything")
        } catch {
            Logger.storage.error("Deleting everything failed: \(error, privacy: .public)")
        }
    }
}
