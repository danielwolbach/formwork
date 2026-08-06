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
            Section(.sectionPending) {
                ForEach(session.pending, id: \.id) { entry in
                    SessionQueueRow(entry: entry)
                }
                .onMove(perform: movePending)
            }

            if !completedEntries.isEmpty {
                Section(.sectionCompleted) {
                    ForEach(completedEntries, id: \.id) { entry in
                        CompletedEntryRow(entry: entry, undo: undo)
                    }
                }
            }
        }
        .navigationTitle(.screenQueue)
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

    private var completedEntries: [SessionEntry] {
        session.completed
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
            IconRow(icon: entry.icon, color: entry.color, title: entry.title, subtitle: entry.subtitle)
        }
    }
}

private struct CompletedEntryRow: View {
    let entry: SessionEntry
    let undo: (SessionEntry) -> Void

    var body: some View {
        HStack {
            SessionQueueRow(entry: entry)

            Button(.undo) {
                undo(entry)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.tertiary)
            .padding(.horizontal, 6)
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
