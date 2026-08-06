//
//  SessionPlayerScreen.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 12.07.26.
//

import SwiftData
import SwiftUI

struct SessionPlayerScreen: View {
    @Environment(\.dismiss) private var dismiss: DismissAction
    @Environment(\.modelContext) private var modelContext: ModelContext
    @State private var navigationDirection: SessionNavigationDirection = .forward
    @State private var queuePresented = false
    @State private var finishSessionAlert = false
    @State private var cancelSessionAlert = false
    @Bindable var session: Session

    var body: some View {
        ScreenStack {
            SessionEntryDetail(entry: session.current)
                .id(session.current.id)
                .frame(maxWidth: .infinity)
                .transition(navigationDirection.transition)

            Spacer()

            SessionEntryControls(
                session: session,
                navigationDirection: $navigationDirection,
                finishSessionAlert: $finishSessionAlert
            )
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(.actionMinimize, systemImage: "chevron.down") {
                    dismiss()
                }
            }

            ToolbarItemGroup(placement: .topBarTrailing) {
                Menu(.moreOptions) {
                    Section {
                        Button(.queue) {
                            queuePresented = true
                        }

                        Button(.finishSession) {
                            finishSessionAlert = true
                        }
                    }

                    Section {
                        Button(.cancelSession) {
                            cancelSessionAlert = true
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $queuePresented) {
            NavigationStack {
                SessionQueueScreen(session: session)
            }
        }
        .alert(.alertFinishSessionTitle, isPresented: $finishSessionAlert) {
            Button(.finishSession) {
                finishSession()
            }

            Button(.cancel) {}
        } message: {
            Text(.alertFinishSessionMessage)
        }
        .alert(.alertCancelSessionTitle, isPresented: $cancelSessionAlert) {
            Button(.actionSessionCancel, role: .destructive) {
                cancelSession()
            }

            Button(.cancel) {}
        } message: {
            Text(.alertCancelSessionMessage)
        }
    }

    private func finishSession() {
        do {
            try modelContext.finishSession(session)
            dismiss()
        } catch {
            fatalError("Failed to finish session: \(error)")
        }
    }

    private func cancelSession() {
        do {
            try modelContext.cancelSession(session)
            dismiss()
        } catch {
            fatalError("Failed to cancel session: \(error)")
        }
    }
}

#Preview {
    SessionPlayerScreen(session: Session.samples[0])
}

private struct SessionEntryControls: View {
    @Bindable var session: Session
    @Binding var navigationDirection: SessionNavigationDirection
    @Binding var finishSessionAlert: Bool

    var body: some View {
        VStack(spacing: 32) {
            ButtonStack {
                Button(.backward) {
                    navigate(.backward) { session.moveToPrevious() }
                }
                .disabled(session.previous == nil)
                .buttonStyle(.glass)
                .labelStyle(.fixedIconOnly)
                .buttonBorderShape(.circle)

                primaryAction
                    .buttonStyle(.glassProminent)
                    .labelStyle(.fixedTitleAndIcon)

                Button(.forward) {
                    navigate(.forward) { session.moveToNext() }
                }
                .disabled(session.next == nil)
                .buttonStyle(.glass)
                .labelStyle(.fixedIconOnly)
                .buttonBorderShape(.circle)
            }

            secondaryAction
                .buttonStyle(.glass)
                .labelStyle(.fixedTitleAndIcon)
                .controlSize(.small)
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private var primaryAction: some View {
        if session.pending.isEmpty {
            Button(.finishSession) { finishSessionAlert = true }
                .fontWeight(.semibold)
        } else if session.current.status == .pending {
            Button(.complete) {
                navigate(.forward) { session.completeAndAdvance() }
            }
            .fontWeight(.semibold)
            .tint(.green)
        } else {
            Button(session.current.status.title, systemImage: session.current.status.icon) {}
                .fontWeight(.semibold)
                .disabled(true)
        }
    }

    @ViewBuilder
    private var secondaryAction: some View {
        if session.current.status == .pending {
            Button(.skip) {
                navigate(.forward) { session.skipAndAdvance() }
            }
        } else {
            Button(.undo) {
                withAnimation(.snappy) { session.undoStatusChange() }
            }
        }
    }

    private func navigate(_ direction: SessionNavigationDirection, action: @escaping () -> Void) {
        var transaction = Transaction()
        transaction.disablesAnimations = true

        withTransaction(transaction) {
            navigationDirection = direction
        }

        withAnimation(.snappy(), action)
    }
}
