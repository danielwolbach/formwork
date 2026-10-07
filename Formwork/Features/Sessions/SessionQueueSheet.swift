//
//  SessionQueueSheet.swift
//  Formwork
//
//  Created by Daniel Wolbach on 06.10.26.
//

import FormworkKit
import FormworkUI
import SwiftUI

struct SessionQueueSheet: View {
    private let session: Session

    @Environment(\.dismiss)
    private var dismiss: DismissAction

    @Environment(\.units)
    private var units: Units

    @State
    private var sheet: Sheet? = nil

    init(_ session: Session) {
        self.session = session
    }

    var body: some View {
        let pendingEntries = session.pendingEntries

        ScrollView {
            ContentStack {
                SectionView(.fieldPendingTitle) {
                    if !pendingEntries.isEmpty {
                        LazyVStack(spacing: 0) {
                            ForEach(pendingEntries) { entry in
                                HStack {
                                    Button {
                                        session.currentEntry = entry
                                        dismiss()
                                    } label: {
                                        PictogramRow(
                                            entry.pictogram,
                                            title: entry.title,
                                            subtitle: entry.target.formatted(.exerciseTarget(units: units))
                                        )
                                    }
                                    .buttonStyle(.plain)

                                    Image(systemName: "line.3.horizontal")
                                        .foregroundStyle(.tertiary)
                                        .accessibilityHidden(true)
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                .swipeActions(edge: .trailing) {
                                    if entry.isAddedWithoutWorkout {
                                        Button(.remove) {
                                            session.remove(entry)
                                        }
                                        .labelStyle(.fixedIconOnly)
                                    } else {
                                        Button(.skip) {
                                            session.skip(entry)
                                        }
                                        .tint(.orange)
                                        .labelStyle(.fixedIconOnly)
                                    }
                                }
                            }
                            .reorderable()
                        }
                        .reorderContainer(for: SessionEntry.self) { difference in
                            var pending = pendingEntries
                            pending.apply(difference: difference)
                            session.reorderPending(pending)
                        }
                        .swipeActionsContainer()
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial)
                        .clipShape(.rect(cornerRadius: 16, style: .continuous))
                    } else {
                        GroupBox {
                            Text(.emptyWorkoutEntriesTitle)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, minHeight: 64)
                        }
                    }
                } accessory: {
                    Button(.addExercises) {
                        sheet = .sessionAddEntries(session)
                    }
                    .buttonStyle(.cardProminent)
                    .labelStyle(.fixedTitleAndIcon)
                }

                if !session.resolvedEntries.isEmpty {
                    SectionView(.fieldResolvedTitle) {
                        LazyVStack(spacing: 0) {
                            ForEach(session.resolvedEntries) { entry in
                                HStack {
                                    Button {
                                        session.currentEntry = entry
                                        dismiss()
                                    } label: {
                                        PictogramRow(
                                            entry.pictogram,
                                            title: entry.title,
                                            subtitle: entry.target.formatted(.exerciseTarget(units: units)),
                                            badge: entry.status.isPending ? nil : entry.status.pictogram
                                        )
                                    }
                                    .buttonStyle(.plain)

                                    Button(.undo) {
                                        session.undo(entry)
                                    }
                                    .labelStyle(.fixedIconOnly)
                                    .buttonStyle(.plain)
                                    .foregroundStyle(.tertiary)
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                .accessibilityValue(entry.status.title)
                            }
                        }
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial)
                        .clipShape(.rect(cornerRadius: 16, style: .continuous))
                    }
                }
            }
        }
        .groupBoxStyle(.card)
        .contentMargins(.vertical, .sections, for: .scrollContent)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .animation(.snappy, value: session.pendingEntries.count)
        .animation(.snappy, value: session.resolvedEntries.count)
        .sheet(item: $sheet) { sheet in
            sheet
        }
    }

    private func undo(_ entry: SessionEntry) {
        session.undo(entry)
    }
}

#Preview {
    NavigationRoot {
        SessionQueueSheet(Samples.activeSession)
    }
    .sampleData()
}
