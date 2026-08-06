//
//  SessionMiniPlayer.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 13.07.26.
//

import SwiftData
import SwiftUI

struct SessionMiniPlayer: View {
    @Environment(\.presentSession) private var presentSession: PresentSessionAction

    let session: Session
    let transitionNamespace: Namespace.ID

    var body: some View {
        HStack {
            Button {
                presentSession(session)
            } label: {
                ZStack(alignment: .leading) {
                    SessionMiniPlayerEntry(entry: session.current)
                        .id(session.current.id)
                        .transition(SessionNavigationDirection.forward.transition)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(.rect)
            }
            .buttonStyle(.plain)

            SessionMiniPlayerControls(
                status: session.current.status,
                complete: completeCurrentEntry,
                undo: undoCurrentEntry,
                advance: advanceToNextEntry
            )
        }
        .padding(.horizontal)
        .matchedTransitionSource(id: session.persistentModelID, in: transitionNamespace)
    }

    private func navigate(action: @escaping () -> Void) {
        withAnimation(.snappy()) {
            action()
        }
    }

    private func completeCurrentEntry() {
        if session.pending.count == 1 {
            presentSession(session)
        }

        navigate {
            session.completeAndAdvance()
        }
    }

    private func undoCurrentEntry() {
        withAnimation(.snappy) {
            session.undoStatusChange()
        }
    }

    private func advanceToNextEntry() {
        navigate {
            if let next = session.next {
                session.current = next
            } else if let firstEntry = session.firstEntry {
                session.current = firstEntry
            }
        }
    }
}

private struct SessionMiniPlayerControls: View {
    let status: SessionEntry.Status
    let complete: () -> Void
    let undo: () -> Void
    let advance: () -> Void

    var body: some View {
        HStack {
            statusAction

            Button(.forward, action: advance)
                .labelStyle(.fixedIconOnly)
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
        }
    }

    @ViewBuilder
    private var statusAction: some View {
        switch status {
        case .pending:
            Button(.complete, action: complete)
                .fontWeight(.bold)
                .tint(.green)
                .labelStyle(.fixedIconOnly)
                .buttonStyle(.glassProminent)
                .buttonBorderShape(.circle)

        case .done, .skipped:
            Button(.undo, action: undo)
                .labelStyle(.fixedIconOnly)
                .buttonStyle(.glassProminent)
                .buttonBorderShape(.circle)
        }
    }
}

private struct SessionMiniPlayerEntry: View {
    let entry: SessionEntry

    var body: some View {
        HStack {
            IconBadge(icon: entry.icon, color: entry.color, size: 32)

            VStack(alignment: .leading, spacing: 0) {
                Text(entry.exercise.name)
                    .font(.caption)

                Text(entry.subtitle)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }
}

private struct SessionMiniPlayerPreview: View {
    @Query(sort: \Session.started, order: .reverse) private var sessions: [Session]
    @Namespace private var namespace

    var body: some View {
        TabView {}
            .tabViewBottomAccessory(isEnabled: !sessions.isEmpty) {
                if let session = sessions.activeSession {
                    SessionMiniPlayer(
                        session: session,
                        transitionNamespace: namespace
                    )
                }
            }
    }
}

#Preview {
    SessionMiniPlayerPreview()
        .sampleData()
}
