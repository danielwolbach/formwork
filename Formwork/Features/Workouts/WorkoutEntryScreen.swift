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
    @Bindable
    var entry: WorkoutEntry

    @Environment(\.modelContext)
    private var modelContext: ModelContext

    @Environment(\.dismiss)
    private var dismiss: DismissAction

    @State
    private var sheet: Sheet? = nil

    @State
    private var deleteAlert: Bool = false

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
                    .padding(.vertical)

                if let exercise = entry.exercise {
                    ExerciseGuide(exercise: exercise)
                }
            }
            .padding(.bottom)
        }
        .scrollDismissesKeyboard(.interactively)
        .toolbar {
            Menu(.more) {
                Section {
                    if entry.exercise != nil {
                        Button(.viewStatistics) {
                            sheet = .viewStatistics(entry: entry)
                        }
                    }
                }

                Section {
                    Menu(.unit) {
                        ExerciseTargetUnitPicker(target: $entry.target)
                    }

                    if let exercise = entry.exercise {
                        Button(.edit) {
                            sheet = .editExercise(exercise: exercise)
                        }
                    }
                }

                Section {
                    Button(.remove) {
                        deleteAlert = true
                    }
                }
            }
        }
        .sheet(item: $sheet) { $0 }
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
