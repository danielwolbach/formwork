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

    @Bindable var entry: WorkoutEntry

    var body: some View {
        ScrollView {
            ScreenStack {
                DetailHero(
                    title: entry.exercise.name,
                    subtitle: entry.target.metric.description,
                    systemImage: entry.exercise.systemImage,
                    color: entry.exercise.color
                )

                ExerciseTargetEditor(target: $entry.target)
                    .padding(.horizontal)
            }
        }
        .toolbar {
            Menu(.moreOptions) {
                Section {
                    Menu(.metric) {
                        Picker(ActionDescriptor.metric.title, selection: metric) {
                            ForEach(ExerciseMetric.allCases) { metric in
                                Label(metric.description, systemImage: metric.systemImage)
                                    .tag(metric)
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
        .onChange(of: entry.target) {
            save()
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

    private var metric: Binding<ExerciseMetric> {
        Binding {
            entry.target.metric
        } set: { metric in
            withAnimation(.snappy(duration: 0.25)) {
                entry.target = .defaults(for: metric)
            }
        }
    }

    private func save() {
        do {
            try modelContext.save()
        } catch {
            fatalError("Failed to save workout entry: \(error)")
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
