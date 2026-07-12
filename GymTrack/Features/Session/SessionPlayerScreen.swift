//
//  SessionScreen.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 12.07.26.
//

import SwiftData
import SwiftUI

struct SessionPlayerScreen: View {
    @Environment(\.modelContext) private var modelContext: ModelContext
    @Environment(\.dismiss) private var dismiss: DismissAction
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
                Button("Minimize", systemImage: "chevron.down") {
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
        .alert("Finish Session?", isPresented: $finishSessionAlert) {
            Button(.finishSession) {
                finishSession()
            }

            Button(.cancel) {}
        } message: {
            Text("This will end the active session.")
        }
        .alert("Cancel Session?", isPresented: $cancelSessionAlert) {
            Button("Cancel Session", role: .destructive) {
                cancelSession()
            }

            Button(.cancel) {}
        } message: {
            Text("This will discard the active session.")
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
