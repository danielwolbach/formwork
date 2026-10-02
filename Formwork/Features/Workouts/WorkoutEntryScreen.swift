//
//  WorkoutEntryScreen.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import FormworkKit
import FormworkUI
import SwiftData
import SwiftUI

struct WorkoutEntryScreen: View {
    private let entry: WorkoutEntry

    @Environment(\.modelContext)
    private var context: ModelContext

    @Environment(\.dismiss)
    private var dismiss: DismissAction

    @Environment(\.fullVersion)
    private var fullVersion: FullVersion

    @Environment(\.presentPaywall)
    private var presentPaywall: PresentPaywallAction

    @State
    private var sheet: Sheet? = nil

    @State
    private var deleteAlert: Bool = false

    init(_ entry: WorkoutEntry) {
        self.entry = entry
    }

    var body: some View {
        let badge = entry.isArchived ? Pictogram.archivedBadge : nil

        ScrollView {
            ContentStack {
                // The exercise's categories rather than the entry's target, which the editor below shows.
                PictogramHeader(
                    entry.pictogram,
                    title: entry.title,
                    subtitle: entry.exercise?.categories.formatted(.exerciseCategories),
                    badge: badge
                )

                ExerciseTargetEditor(target: Bindable(entry).target)

                if let exercise = entry.exercise {
                    ExerciseGuide(exercise)
                }
            }
        }
        .contentMargins(.bottom, .sections, for: .scrollContent)
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

                        if exercise.isArchived {
                            Button(.unarchive) {
                                unarchive()
                            }
                        } else {
                            Button(.archive) {
                                archive()
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
        .sheet(item: $sheet) { sheet in
            sheet
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

    /// Archiving acts on the exercise, so it applies to every workout using it and to the catalog.
    private func archive() {
        entry.exercise?.isArchived = true
    }

    private func unarchive() {
        guard fullVersion.canAddExercise(in: context) else {
            presentPaywall()
            return
        }

        entry.exercise?.isArchived = false
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
