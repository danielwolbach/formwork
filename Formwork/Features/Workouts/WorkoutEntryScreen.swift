//
//  WorkoutEntryScreen.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import FormworkKit
import SwiftData
import SwiftUI

struct WorkoutEntryScreen: View {
    @Environment(\.modelContext) private var modelContext: ModelContext
    @Environment(\.dismiss) private var dismiss: DismissAction
    @State private var deleteAlert: Bool = false
    
    @Bindable var entry: WorkoutEntry

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Show the exercise's categories, not the entry's target since
                // the target editor below already shows it.
                PictogramHeader(
                    pictogram: entry.pictogram,
                    title: entry.title,
                    subtitle: entry.exercise?.subtitle
                )

                ExerciseTargetEditor(target: $entry.target)
            }
        }
        .toolbar {
            Menu(.more) {
                Section {
                    Menu(.unit) {
                        ExerciseTargetUnitPicker(target: $entry.target)
                    }
                }

                Section {
                    Button(.remove) {
                        delete()
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
        WorkoutEntryScreen(entry: Samples.workouts.first!.entries[1])
    }
}
