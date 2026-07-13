//
//  SessionQueueScreen.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 13.07.26.
//

import SwiftData
import SwiftUI

struct SessionQueueScreen: View {
    @Environment(\.dismiss) private var dismiss: DismissAction
    @Environment(\.modelContext) private var modelContext: ModelContext
    @Bindable var session: Session

    var body: some View {
        Form {
            Section("Pending") {
                ForEach(session.pending) { entry in
                    SessionQueueRow(entry: entry)
                }
                .onMove(perform: movePending)
            }

            if !session.completed.isEmpty {
                Section("Completed") {
                    ForEach(session.completed) { entry in
                        HStack {
                            SessionQueueRow(entry: entry)

                            IconButton(.undo, style: .plain) {
                                undo(entry)
                            }
                            .foregroundStyle(.tertiary)
                            .padding(.horizontal, 6)
                        }
                    }
                }
            }
        }
        .navigationTitle("Queue")
        .navigationBarTitleDisplayMode(.inline)
        .environment(\.editMode, .constant(.active))
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(.confirm) {
                    dismiss()
                }
            }
        }
    }

    private func movePending(from source: IndexSet, to destination: Int) {
        var entries = session.pending
        entries.move(fromOffsets: source, toOffset: destination)

        withAnimation(.snappy) {
            session.reorderPending(entries)
        }

        save()
    }

    private func undo(_ entry: SessionEntry) {
        withAnimation(.snappy) {
            session.undoStatusChange(for: entry)
        }

        save()
    }

    private func save() {
        do {
            try modelContext.save()
        } catch {
            fatalError("Failed to save session queue: \(error)")
        }
    }
}

private struct SessionQueueRow: View {
    let entry: SessionEntry

    var body: some View {
        HStack {
            IconTile(
                systemImage: entry.systemImage,
                color: entry.color,
                size: .small
            )

            VStack(alignment: .leading, spacing: 0) {
                Text(entry.exercise.name)

                entry.subtitle
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }
}

private struct SessionQueueScreenPreview: View {
    @Query(sort: \Session.started, order: .reverse) private var sessions: [Session]

    var body: some View {
        NavigationStack {
            if let session = sessions.activeSession {
                SessionQueueScreen(session: session)
            }
        }
    }
}

#Preview {
    SessionQueueScreenPreview()
        .sampleData()
}
