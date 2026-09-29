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
    private let entry: WorkoutEntry

    @Environment(\.modelContext)
    private var context: ModelContext

    @Environment(\.dismiss)
    private var dismiss: DismissAction

    @State
    private var sheet: Sheet? = nil

    @State
    private var deleteAlert: Bool = false

    init(_ entry: WorkoutEntry) {
        self.entry = entry
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // The exercise's categories rather than the entry's target, which the editor below shows.
                DisplayableHeader(pictogram: entry.pictogram, title: entry.title, subtitle: entry.exercise?.subtitle)

                ExerciseTargetEditor(target: Bindable(entry).target)
                    .padding(.horizontal)

                if let exercise = entry.exercise {
                    ExerciseGuide(exercise)
                        .padding(.horizontal)
                }
            }
        }
        .toolbar {
            Menu(.more) {
                Section {
                    Button(.viewStatistics) {
                        sheet = .workoutEntryStatistics(entry)
                    }
                }

                Section {
                    if let exercise = entry.exercise {
                        Button(.edit) {
                            sheet = .editExercise(exercise)
                        }
                    }

                    Button(.remove) {
                        deleteAlert = true
                    }
                }
            }
        }
        .sheet(item: $sheet) { sheet in
            NavigationStack {
                sheet
            }
        }
        .alert(.alertRemoveWorkoutEntryTitle, isPresented: $deleteAlert) {
            Button(.cancel) {
                // Works automatically.
            }

            Button(.remove) {
                remove()
            }
        } message: {
            Text(.alertRemoveWorkoutEntryMessage)
        }
    }

    private func remove() {
        context.delete(entry)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        WorkoutEntryScreen(Samples.workouts.first!.entries.first!)
    }
}
