//
//  SessionMiniPlayer.swift
//  Formwork
//
//  Created by Daniel Wolbach on 05.09.26.
//

import FormworkKit
import SwiftData
import SwiftUI

struct SessionMiniPlayer: View {
    @Environment(\.presentSession) private var presentSession: PresentSessionAction
    @State private var direction: SlideDirection = .forward

    let session: Session
    let transitionNamespace: Namespace.ID

    var body: some View {
        HStack(spacing: 0) {
            entry

            sessionProgress
                .padding(.trailing)

            controls
                .padding(.trailing)
        }
        .matchedTransitionSource(id: session.persistentModelID, in: transitionNamespace)
    }

    private var entry: some View {
        SlideStack(
            key: session.current?.identifier,
            direction: direction,
            fade: 16,
            canMoveForward: session.next != nil,
            canMoveBackward: session.previous != nil,
            onForward: advanceToNextEntry,
            onBackward: returnToPreviousEntry
        ) { identifier in
            if let current = session.entry(identifiedBy: identifier) {
                HStack {
                    PictogramView(
                        pictogram: current.pictogram,
                        size: 32,
                        badge: current.status.isPending ? nil : current.status.pictogram
                    )

                    VStack(alignment: .leading, spacing: 0) {
                        Text(current.title)
                            .font(.caption)

                        Text(current.subtitle)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()
                }
                .padding(.horizontal)
                .contentShape(.rect)
                .accessibilityAddTraits(.isButton)
                .onTapGesture {
                    presentSession(session)
                }
            }
        }
    }

    private var controls: some View {
        statusAction
    }

    @ViewBuilder
    private var statusAction: some View {
        if session.isComplete {
            Button(.finishSession) {
                presentSession(session)
            }
            .fontWeight(.bold)
            .labelStyle(.fixedIconOnly)
            .buttonStyle(.glassProminent)
            .buttonBorderShape(.circle)
        } else {
            pendingStatusAction
        }
    }

    @ViewBuilder
    private var pendingStatusAction: some View {
        switch session.current?.status {
        case .pending:
            Button(.complete, action: completeCurrentEntry)
                .fontWeight(.bold)
                .tint(.green)
                .labelStyle(.fixedIconOnly)
                .buttonStyle(.glassProminent)
                .buttonBorderShape(.circle)

        case .completed, .skipped:
            Button(.undo, action: undoCurrentEntry)
                .labelStyle(.fixedIconOnly)
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)

        case nil:
            EmptyView()
        }
    }

    private var sessionProgress: some View {
        Text(verbatim: session.progressText)
            .font(.caption2)
            .monospacedDigit()
            .foregroundStyle(.secondary)
    }

    private func completeCurrentEntry() {
        Haptics.impact(.medium)
        direction = .forward
        session.completeAndAdvance()
    }

    private func undoCurrentEntry() {
        session.undoStatusChange()
    }

    private func advanceToNextEntry() {
        direction = .forward
        session.moveToNext()
    }

    private func returnToPreviousEntry() {
        direction = .backward
        session.moveToPrevious()
    }
}

#Preview {
    @Previewable @Namespace var namespace

    TabView {}
        .tabViewBottomAccessory {
            SessionMiniPlayer(session: Samples.session, transitionNamespace: namespace)
        }
        .sampleData()
}
