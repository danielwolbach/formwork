//
//  WorkoutEntryDetailScreen.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import SwiftData
import SwiftUI

struct WorkoutEntryDetailScreen: View {
    @Environment(\.modelContext) private var modelContext: ModelContext
    @Environment(\.dismiss) private var dismiss: DismissAction

    @State private var deleteAlert = false

    let entry: WorkoutEntry

    var body: some View {
        ScrollView {
            ScreenStack {
                DetailHero(
                    title: entry.exercise.name,
                    subtitle: entry.exercise.metric.description,
                    systemImage: entry.exercise.systemImage,
                    color: entry.exercise.color
                )

                // TODO:
            }
        }
        .toolbar {
            Menu(.moreOptions) {
                Section {
                    Menu(.metric) {
                        Picker(ActionDescriptor.metric.title, selection: .constant(ExerciseMetric.weight)) { // TODO:
                            ForEach(ExerciseMetric.allCases) { metric in
                                Label(metric.description, systemImage: metric.systemImage)
                            }
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
        .alert("Remove Exercise?", isPresented: $deleteAlert) {
            Button(.remove) {
                remove()
            }

            Button(.cancel) {}
        } message: {
            Text("This will remove the exercise from the workout. This cannot be undone.")
        }
    }

    private func remove() {
        modelContext.delete(entry)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            fatalError("Failed to remove workout entry: \(error)")
        }
    }
}

#Preview {
    NavigationStack {
        WorkoutEntryDetailScreen(entry: WorkoutEntry.samples[0])
    }
}
