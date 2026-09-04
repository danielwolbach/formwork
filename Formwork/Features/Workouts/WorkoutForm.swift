//
//  WorkoutForm.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import SwiftData
import SwiftUI

struct WorkoutForm: View {
    @Environment(\.dismiss) private var dismiss: DismissAction
    @Environment(\.modelContext) private var modelContext: ModelContext
    @State private var name: String
    @State private var entries: [WorkoutEntry]
    
    let workout: Workout?
    
    init(workout: Workout? = nil) {
        self._name = State(initialValue: workout?.name ?? "")
        self._entries = State(initialValue: workout?.entries.sorted() ?? [])
        self.workout = workout
    }
    
    var body: some View {
        Form {
            Section(.fieldNameTitle) {
                TextField(workout?.name ?? String(localized: .fieldNameTitle), text: $name)
            }
            
            if !entries.isEmpty {
                Section(.fieldWorkoutEntriesTitle) {
                    ForEach(entries) { entry in
                        WorkoutEntryRow(entry: entry)
                    }
                    .onMove { source, destination in
                        entries.move(fromOffsets: source, toOffset: destination)
                    }
                }
            }
        }
        .navigationTitle(workout == nil ? .screenWorkoutCreateTitle : .screenWorkoutEditTitle)
        .navigationBarTitleDisplayMode(.inline)
        .environment(\.editMode, .constant(.active))
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
    
    private var valid: Bool {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return !name.isEmpty
    }
    
    private func save() {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        for (index, entry) in entries.enumerated() { entry.order = index }
    
        if let workout {
            workout.name = name
        } else {
            let workout = Workout(name: name, entries: entries)
            modelContext.insert(workout)
        }
        
        dismiss()
    }
}

private struct WorkoutEntryRow: View {
    let entry: WorkoutEntry
    
    var body: some View {
        DisplayableRow(displayable: entry)
    }
}

#Preview("Create") {
    NavigationStack {
        WorkoutForm()
    }
}

#Preview("Edit") {
    NavigationStack {
        WorkoutForm(workout: Samples.workouts.first!)
    }
}
