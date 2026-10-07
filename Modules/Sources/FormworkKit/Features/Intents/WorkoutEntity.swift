//
//  WorkoutEntity.swift
//  FormworkModules
//
//  Created by Daniel Wolbach on 07.10.26.
//

import AppIntents
import SwiftData

public struct WorkoutEntity: IndexedEntity {
    /// Resolved from the app's catalog: the system reads intent strings from the main bundle, never this package's.
    public static let typeDisplayRepresentation: TypeDisplayRepresentation = "intent.workout.title"

    public static let defaultQuery: WorkoutEntityQuery = .init()

    public let id: UUID

    @Property(indexingKey: \.displayName)
    public var name: String

    @Property(indexingKey: \.contentDescription)
    public var details: String

    public let image: String

    init(_ workout: Workout) {
        self.id = workout.id
        self.image = workout.pictogram.image
        self.name = workout.name
        self.details = workout.formatted(.workoutDetails)
    }

    public var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: LocalizedStringResource(stringLiteral: name),
            subtitle: LocalizedStringResource(stringLiteral: details),
            image: .init(systemName: image)
        )
    }
}

public struct WorkoutEntityQuery: EntityQuery {
    public init() {
        // Nothing to initialize.
    }

    public func entities(for identifiers: [UUID]) async throws -> [WorkoutEntity] {
        let context = await ModelContext(Storage.container)
        let descriptor = FetchDescriptor<Workout>(predicate: #Predicate { identifiers.contains($0.id) })
        return try context.fetch(descriptor).map(WorkoutEntity.init)
    }

    public func suggestedEntities() async throws -> [WorkoutEntity] {
        let context = await ModelContext(Storage.container)
        let descriptor = FetchDescriptor<Workout>(predicate: #Predicate { !$0.isArchived }, sortBy: [SortDescriptor(\.name)])
        return try context.fetch(descriptor).map(WorkoutEntity.init)
    }
}
