//
//  WorkoutEntity.swift
//  FormworkModules
//
//  Created by Daniel Wolbach on 07.10.26.
//

import AppIntents
import SwiftData

public struct WorkoutEntity: IndexedEntity {
    public let id: UUID
    
    @Property(indexingKey: \.displayName)
    public var name: String
    
    @Property(indexingKey: \.contentDescription)
    public var details: String
    
    public let image: String
    
    init(_ workout: Workout) {
        id = workout.id
        image = workout.pictogram.image
        name = workout.name
        details = workout.formatted(.workoutDetails)
    }
    
    public var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: LocalizedStringResource(stringLiteral: name),
            subtitle: LocalizedStringResource(stringLiteral: details),
            image: .init(systemName: image)
        )
    }
    
    // Resolved from the app's catalog: the system reads intent strings from the main bundle, never this package's.
    public static let typeDisplayRepresentation: TypeDisplayRepresentation = "intent.workout.title"
    
    public static let defaultQuery: WorkoutEntityQuery = .init()
}

public struct WorkoutEntityQuery: EntityQuery {
    public init() {
        // Nothing to initialize.
    }
    
    public func entities(for identifiers: [UUID]) async throws -> [WorkoutEntity] {
        let context = ModelContext(await Storage.container)
        let descriptor = FetchDescriptor<Workout>(predicate: #Predicate { identifiers.contains($0.id) })
        return try context.fetch(descriptor).map(WorkoutEntity.init)
    }
    
    public func suggestedEntities() async throws -> [WorkoutEntity] {
        let context = ModelContext(await Storage.container)
        let descriptor = FetchDescriptor<Workout>(predicate: #Predicate { !$0.isArchived }, sortBy: [SortDescriptor(\.name)])
        return try context.fetch(descriptor).map(WorkoutEntity.init)
    }
}
