//
//  WorkoutEntryDetailScreen.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import SwiftData
import SwiftUI

struct WorkoutEntryDetailScreen: View {
    @Environment(\.dismiss) private var dismiss: DismissAction
    @Environment(\.modelContext) private var modelContext: ModelContext
    @State private var deleteAlert = false
    @Bindable var entry: WorkoutEntry

    var body: some View {
        ScrollView {
            ScreenStack {
                IconHero(
                    icon: entry.icon,
                    color: entry.color,
                    title: entry.title,
                    subtitle: String(localized: entry.target.type.title)
                )

                ExerciseTargetEditor(target: $entry.target)
                    .padding(.horizontal)
            }
        }
        .toolbar {
            Menu(.moreOptions) {
                Button(.remove) {
                    deleteAlert = true
                }
            }
        }
        .onChange(of: entry.target) {
            save()
        }
        .alert(.alertRemoveExerciseTitle, isPresented: $deleteAlert) {
            Button(.remove) {
                remove()
            }

            Button(.cancel) {}
        } message: {
            Text(.alertRemoveExerciseMessage)
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
        do {
            modelContext.delete(entry)
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
