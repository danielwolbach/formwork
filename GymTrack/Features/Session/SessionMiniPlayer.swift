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

            HStack(spacing: 0) {
                switch session.current.status {
                case .pending:
                    IconButton(.complete, style: .glassProminent) {
                        if session.pending.count == 1 {
                            presentSession(session)
                        }

                        navigate {
                            session.completeAndAdvance()
                        }
                    }
                    .fontWeight(.bold)
                    .tint(.green)
                    .clipShape(.circle)

                case .done, .skipped:
                    IconButton(.undo) {
                        withAnimation(.snappy) {
                            session.undoStatusChange()
                        }
                    }
                    .clipShape(.circle)
                }

                IconButton(.forward) {
                    navigate {
                        if session.next == nil {
                            session.current = session.entries.sorted()[0]
                        } else {
                            session.moveToNext()
                        }
                    }
                }
                .clipShape(.circle)
            }
        }
        .padding(.horizontal)
        .matchedTransitionSource(id: session.persistentModelID, in: transitionNamespace)
    }

    private func navigate(action: @escaping () -> Void) {
        DispatchQueue.main.async {
            withAnimation(.snappy()) {
                action()
            }
        }
    }
}

private struct SessionMiniPlayerEntry: View {
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
                    .font(.caption)

                entry.subtitle
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }
}

private struct SessionMiniPlayerPreview: View {
    @Query private var sessions: [Session]
    @Namespace private var namespace

    var body: some View {
        TabView {}
            .tabViewBottomAccessory(isEnabled: !sessions.isEmpty) {
                if let session = sessions.first {
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
