//
//  Schema.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 20.09.26.
//

import SwiftData

public typealias CurrentSchema = SchemaV1

public enum Migrations: SchemaMigrationPlan {
    public static let schemas: [any VersionedSchema.Type] = [SchemaV1.self]
    public static let stages: [MigrationStage] = []
}

public enum SchemaV1: VersionedSchema {
    public static let versionIdentifier = Schema.Version(1, 0, 0)

    public static let models: [any PersistentModel.Type] = [
        Exercise.self,
        Workout.self,
        WorkoutEntry.self,
        Session.self,
        SessionEntry.self,
    ]
}
