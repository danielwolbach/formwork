//
//  WorkoutEntryScreen.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import SwiftData
import SwiftUI

struct WorkoutEntryScreen: View {
    @Environment(\.modelContext) private var modelContext: ModelContext
    @Environment(\.dismiss) private var dismiss: DismissAction
    @State private var deleteAlert: Bool = false

    @Bindable var entry: WorkoutEntry

    var body: some View {
        ScreenStack {
            DisplayableHero(displayable: entry.exercise!)

            ExerciseTargetView(target: $entry.target)
        }
        .toolbar {
            Menu(.more) {
                Section {
                    Button(.remove) {
                        deleteAlert = true
                    }
                }
            }
        }
        .alert(.alertWorkoutEntryRemoveTitle, isPresented: $deleteAlert) {
            Button(.remove) {
                delete()
            }

            Button(.cancel) {}
        } message: {
            Text(.alertWorkoutEntryRemoveMessage)
        }
    }

    private func delete() {
        modelContext.delete(entry)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        WorkoutEntryScreen(entry: Samples.workoutEntries.first!)
    }
}
