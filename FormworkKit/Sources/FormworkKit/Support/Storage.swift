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
        try! ModelContainer(for: schema, configurations: [ModelConfiguration(schema: schema)])
    }
}
