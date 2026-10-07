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

    @Environment(\.paywall)
    private var paywall: Paywall

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

            if let exercise = entry.exercise {
                Section {
                    Button(.edit) {
                        sheet = .editExercise(exercise)
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
            Button(.viewStatistics) {
                sheet = .workoutEntryStatistics(entry)
            }
            .labelStyle(.fixedIconOnly)
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
