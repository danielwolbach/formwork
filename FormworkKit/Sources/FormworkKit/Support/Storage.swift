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
    public static let schema = Schema([Exercise.self, Workout.self, WorkoutEntry.self, Session.self, SessionEntry.self])

    public static let container: ModelContainer = if ProcessInfo.processInfo.arguments.contains("--sample-data") {
        Samples.container
    } else {
        try unwrap(ModelContainer(for: schema, configurations: [ModelConfiguration(schema: schema)]), "Failed to initialize storage")
    }
}

private func unwrap<T>(_ expression: @autoclosure () throws -> T, _ message: String) -> T {
    do {
        return try expression()
    } catch {
        fatalError("\(message): \(error)")
    }
}
