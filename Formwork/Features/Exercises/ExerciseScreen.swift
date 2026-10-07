//
//  ExerciseScreen.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import FormworkKit
import FormworkUI
import SwiftData
import SwiftUI

struct ExerciseScreen: View {
    private let exercise: Exercise

    @Environment(\.modelContext)
    private var context: ModelContext

    @Environment(\.dismiss)
    private var dismiss: DismissAction

    @Environment(\.paywall)
    private var paywall: Paywall

    @Environment(\.presentPaywall)
    private var presentPaywall: PresentPaywallAction

    @Query(Session.finishedDescriptor)
    private var sessions: [Session]

    @State
    private var sheet: Sheet? = nil

    @State
    private var deleteAlert: Bool = false

    init(_ exercise: Exercise) {
        self.exercise = exercise
    }

    var body: some View {
        let history = History(.exercise(exercise), among: sessions)
        let badge = exercise.isArchived ? Pictogram.archivedBadge : nil

        ScrollView {
            ContentStack {
                PictogramHeader(
                    exercise.pictogram,
                    title: exercise.title,
                    subtitle: exercise.categories.formatted(.exerciseCategories),
                    badge: badge
                )

                if !history.sessions.isEmpty {
                    StatisticGrid(history)
                }

                ExerciseGuide(exercise)
            }
        }
        .contentMargins(.bottom, .sections, for: .scrollContent)
        .toolbar {
            Menu(.more) {
                if !exercise.isArchived {
                    Section {
                        Button(.addToWorkout) {
                            sheet = .exerciseAddToWorkout(exercise)
                        }
                    }
                }

                Section {
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

                Section {
                    Button(.delete) {
                        deleteAlert = true
                    }
                }
            }
        }
        .alert(.alertDeleteExerciseTitle, isPresented: $deleteAlert) {
            Button(.delete) {
                delete()
            }

            if !exercise.isArchived {
                Button(.archive) {
                    archive()
                }
            }

            Button(.cancel) {
                // Works automatically.
            }
        } message: {
            Text(.alertDeleteExerciseMessage)
        }
        .sheet(item: $sheet) { sheet in
            sheet
        }
    }

    private func archive() {
        exercise.isArchived = true
        dismiss()
    }

    private func unarchive() {
        guard paywall.canAddExercise(in: context) else {
            presentPaywall()
            return
        }

        exercise.isArchived = false
    }

    private func delete() {
        context.delete(exercise)
        dismiss()
    }
}

#Preview {
    NavigationRoot {
        ExerciseScreen(Samples.exercises[1])
    }
    .sampleData()
}
