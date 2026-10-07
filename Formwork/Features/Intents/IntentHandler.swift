//
//  IntentHandler.swift
//  Formwork
//
//  Created by Daniel Wolbach on 07.10.26.
//

import AppIntents
import FormworkKit
import FormworkUI
import SwiftData
import SwiftUI

extension View {
    func intentHandler() -> some View {
        modifier(IntentHandler())
    }
}

private struct IntentHandler: ViewModifier {
    @Environment(\.modelContext)
    private var modelContext: ModelContext

    @Environment(\.startSession)
    private var startSession: StartSessionAction

    @State
    private var sheet: Sheet? = nil

    func body(content: Content) -> some View {
        content
            .onAppIntentExecution(OpenWorkoutIntent.self) { intent in
                if let workout = workout(for: intent.target) {
                    sheet = .workout(workout)
                }
            }
            .onAppIntentExecution(StartSessionIntent.self) { intent in
                if let workout = workout(for: intent.workout), !workout.isArchived, workout.isStartable {
                    startSession(workout)
                }
            }
            .sheet(item: $sheet) { sheet in
                sheet
            }
    }

    private func workout(for entity: WorkoutEntity) -> Workout? {
        let id = entity.id
        var descriptor = FetchDescriptor<Workout>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1

        return try? modelContext.fetch(descriptor).first
    }
}
