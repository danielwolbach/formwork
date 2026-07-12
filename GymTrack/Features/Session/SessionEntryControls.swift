//
//  SessionEntryControls.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 13.07.26.
//

import SwiftUI

struct SessionEntryControls: View {
    @Bindable var session: Session
    @Binding var navigationDirection: SessionNavigationDirection
    @Binding var finishSessionAlert: Bool

    var body: some View {
        VStack(spacing: 32) {
            HStack {
                IconButton(.backward) {
                    navigate(.backward) {
                        session.moveToPrevious()
                    }
                }
                .disabled(session.previous == nil)

                primaryAction

                IconButton(.forward) {
                    navigate(.forward) {
                        session.moveToNext()
                    }
                }
                .disabled(session.next == nil)
            }
            .controlSize(.large)

            secondaryAction
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private var primaryAction: some View {
        if session.pending.isEmpty {
            LabelButton(.finishSession, style: .glassProminent) {
                finishSessionAlert = true
            }
            .fontWeight(.semibold)
        } else {
            switch session.current.status {
            case .pending:
                LabelButton(.complete, style: .glassProminent) {
                    navigate(.forward) {
                        session.completeAndAdvance()
                    }
                }
                .fontWeight(.semibold)
                .tint(.green)

            case .done, .skipped:
                LabelButton(
                    session.current.status.title,
                    systemImage: session.current.status.systemImage
                ) {}
                    .fontWeight(.semibold)
                    .tint(.green)
                    .disabled(true)
            }
        }
    }

    @ViewBuilder
    private var secondaryAction: some View {
        switch session.current.status {
        case .pending:
            LabelButton(.skip) {
                navigate(.forward) {
                    session.skipAndAdvance()
                }
            }

        case .done, .skipped:
            LabelButton(.undo) {
                withAnimation(.snappy) {
                    session.undoStatusChange()
                }
            }
        }
    }

    private func navigate(_ direction: SessionNavigationDirection, action: @escaping () -> Void) {
        var transaction = Transaction()
        transaction.disablesAnimations = true

        withTransaction(transaction) {
            navigationDirection = direction
        }

        DispatchQueue.main.async {
            withAnimation(.snappy()) {
                action()
            }
        }
    }
}

enum SessionNavigationDirection {
    case backward
    case forward

    var transition: AnyTransition {
        switch self {
        case .backward:
            .asymmetric(
                insertion: .move(edge: .leading).combined(with: .opacity),
                removal: .move(edge: .trailing).combined(with: .opacity)
            )

        case .forward:
            .asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            )
        }
    }
}
