//
//  WorkoutFormScreen.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import SwiftData
import SwiftUI

struct WorkoutFormScreen: View {
    @Environment(\.dismiss) private var dismiss: DismissAction
    @Environment(\.modelContext) private var modelContext: ModelContext
    @State private var name: String
    @State private var entries: [WorkoutEntry]

    let workout: Workout?

    init(workout: Workout? = nil) {
        _name = State(initialValue: workout?.name ?? "")
        _entries = State(initialValue: workout?.entries.sorted() ?? [])
        self.workout = workout
    }

    var body: some View {
        Form {
            Section(.sectionName) {
                TextField(.placeholderExerciseName, text: $name)
            }

            if !entries.isEmpty {
                Section(.sectionExercises) {
                    ForEach(entries) { entry in
                        IconRow(icon: entry.icon, color: entry.color, title: entry.title, subtitle: entry.subtitle)
                    }
                    .onMove(perform: move)
                }
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .environment(\.editMode, .constant(.active))
        .scrollDismissesKeyboard(.immediately)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(.confirm) {
                    save()
                }
                .disabled(!valid)
            }

            ToolbarItem(placement: .cancellationAction) {
                Button(.cancel) {
                    dismiss()
                }
            }
        }
    }

    private var title: LocalizedStringResource {
        workout == nil ? .screenCreateWorkout : .screenEditWorkout
    }

    private var valid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func save() {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)

        if let workout {
            workout.name = name
            workout.entries = entries
        } else {
            let workout = Workout(name: name, entries: entries)
            modelContext.insert(workout)
        }

        for (index, entry) in entries.enumerated() {
            entry.order = index
        }

        do {
            try modelContext.save()
            dismiss()
        } catch {
            fatalError("Failed to save workout: \(error)")
        }
    }

    private func move(from source: IndexSet, to destination: Int) {
        entries.move(fromOffsets: source, toOffset: destination)
    }
}

#Preview("Create") {
    NavigationStack {
        WorkoutFormScreen()
    }
}

#Preview("Edit") {
    NavigationStack {
        WorkoutFormScreen(workout: Workout.samples[0])
    }
}
