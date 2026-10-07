//
//  WorkoutEntryRow.swift
//  Formwork
//
//  Created by Daniel Wolbach on 29.09.26.
//

import FormworkKit
import FormworkUI
import SwiftData
import SwiftUI

struct WorkoutEntryRow: View {
    private let entry: WorkoutEntry

    @Environment(\.modelContext)
    private var context: ModelContext

    @Environment(\.fullVersion)
    private var fullVersion: FullVersion

    @Environment(\.presentPaywall)
    private var presentPaywall: PresentPaywallAction

    @Environment(\.units)
    private var units: Units

    @State
    private var removeAlert: Bool = false

    @State
    private var sheet: Sheet? = nil

    init(_ entry: WorkoutEntry) {
        self.entry = entry
    }

    var body: some View {
        NavigationLink(value: entry) {
            HStack {
                // Dimmed as well as badged: the entry is skipped in sessions, which should read at a glance.
                PictogramRow(
                    entry.pictogram,
                    title: entry.title,
                    subtitle: entry.target.formatted(.exerciseTarget(units: units)),
                    badge: badge
                )
                .opacity(entry.isArchived ? 0.5 : 1)

                Image(systemName: "chevron.forward")
                    .foregroundStyle(.tertiary)
                    .accessibilityHidden(true)
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .padding(8)
        .contextMenu {
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

                if entry.isArchived {
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
                Button(.remove) {
                    removeAlert = true
                }
            }
        }
        .swipeActions(edge: .leading) {
            if entry.isArchived {
                Button(.unarchive) {
                    unarchive()
                }
                .labelStyle(.fixedIconOnly)
            } else {
                Button(.viewStatistics) {
                    sheet = .workoutEntryStatistics(entry)
                }
                .labelStyle(.fixedIconOnly)
            }
        }
        .swipeActions(edge: .trailing) {
            // No destructive role: it makes SwiftUI expect the row to disappear, so cancelling the alert leaves the button stuck.
            Button(Action.remove.title, systemImage: Action.remove.image) {
                removeAlert = true
            }
            .tint(.red)
            .labelStyle(.fixedIconOnly)
        }
        .alert(.alertRemoveWorkoutEntryTitle, isPresented: $removeAlert) {
            Button(.remove) {
                remove()
            }

            Button(.cancel) {
                // Works automatically.
            }
        } message: {
            Text(.alertRemoveWorkoutEntryMessage)
        }
        .sheet(item: $sheet) { sheet in
            sheet
        }
        .padding(.horizontal, 8)
        .accessibilityValue(entry.isArchived ? Text(.fieldArchivedTitle) : Text(verbatim: ""))
    }

    private var badge: Pictogram? {
        entry.isArchived ? .archivedBadge : nil
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
    }
}

#Preview {
    NavigationRoot {
        WorkoutEntryRow((Samples.workouts.first!.entries ?? []).first!)
    }
    .sampleData()
}
