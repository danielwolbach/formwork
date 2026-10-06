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
        ScrollView {
            ContentStack {
                SectionView(.fieldPendingTitle) {
                    if !session.pendingEntries.isEmpty {
                        LazyVStack(spacing: 0) {
                            ForEach(session.pendingEntries) { entry in
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
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                .swipeActions(edge: .trailing) {
                                    if entry.isAddedWithoutWorkout {
                                        Button(.remove) {
                                            withAnimation(.snappy) {
                                                session.remove(entry)
                                            }
                                        }
                                        .labelStyle(.fixedIconOnly)
                                    } else {
                                        Button(.skip) {
                                            withAnimation(.snappy) {
                                                session.skip(entry)
                                            }
                                        }
                                        .tint(.orange)
                                        .labelStyle(.fixedIconOnly)
                                    }
                                }
                            }
                            .reorderable()
                        }
                        .reorderContainer(for: SessionEntry.self) { difference in
                            var pending = session.pendingEntries
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

                                    Button {
                                        undo(entry)
                                    } label: {
                                        Image(systemName: Action.undo.image)
                                            .foregroundStyle(.tertiary)
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                            }
                        }
                        .swipeActionsContainer()
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
        .sheet(item: $sheet) { sheet in
            sheet
        }
    }

    private func undo(_ entry: SessionEntry) {
        withAnimation(.snappy) {
            session.undo(entry)
        }
    }
}

#Preview {
    NavigationRoot {
        SessionQueueSheet(Samples.activeSession)
    }
    .sampleData()
}
