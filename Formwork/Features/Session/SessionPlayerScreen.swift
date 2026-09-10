//
//  SessionPlayerScreen.swift
//  Formwork
//
//  Created by Daniel Wolbach on 05.09.26.
//

import FormworkKit
import SwiftUI

struct SessionPlayerScreen: View {
    @Environment(\.dismiss) private var dismiss: DismissAction
    @State private var finishAlert: Bool = false
    @State private var cancelAlert: Bool = false
    @State private var direction: SlideDirection = .forward

    let session: Session

    var body: some View {
        currentView
            .safeAreaBar(edge: .bottom, spacing: 0) {
                controls
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    SessionTimer(session: session)
                }

                ToolbarItem(placement: .topBarLeading) {
                    Button(.minimize) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Menu(.more) {
                        Section {
                            Button(.finishSession) {
                                finishAlert = true
                            }
                        }

                        Section {
                            Button(.cancelSession) {
                                cancelAlert = true
                            }
                        }
                    }
                }
            }
            .alert(.alertSessionFinishTitle, isPresented: $finishAlert) {
                Button(.finishSession) {
                    finish()
                }

                Button(.cancel) {}
            } message: {
                Text(.alertSessionFinishMessage)
            }
            .alert(.alertSessionCancelTitle, isPresented: $cancelAlert) {
                Button(.cancelSession) {
                    cancel()
                }

                Button(.cancel) {}
            } message: {
                Text(.alertSessionCancelMessage)
            }
    }

    private var currentView: some View {
        SlideStack(
            key: session.current?.identifier,
            direction: direction,
            canMoveForward: session.next != nil,
            canMoveBackward: session.previous != nil,
            onForward: { advance(.forward) { session.moveToNext() } },
            onBackward: { advance(.backward) { session.moveToPrevious() } }
        ) { identifier in
            if let entry = session.entry(identifiedBy: identifier) {
                @Bindable var entry = entry

                VStack(spacing: 32) {
                    DisplayableHero(displayable: entry.exercise)

                    ExerciseTargetView(target: $entry.target)

                    Spacer()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var controls: some View {
        VStack(spacing: 16) {
            HStack {
                Button(.backward) {
                    advance(.backward) {
                        session.moveToPrevious()
                    }
                }
                .disabled(session.previous == nil)
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
                .labelStyle(.fixedIconOnly)

                primaryAction
                    .buttonStyle(.glassProminent)
                    .labelStyle(.fixedTitleAndIcon)

                Button(.forward) {
                    advance(.forward) {
                        session.moveToNext()
                    }
                }
                .disabled(session.next == nil)
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
                .labelStyle(.fixedIconOnly)
            }
            .controlSize(.large)

            secondaryAction
                .buttonStyle(.borderless)
                .labelStyle(.fixedTitleAndIcon)
                .foregroundStyle(.secondary)
                .controlSize(.small)
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private var primaryAction: some View {
        if session.isComplete {
            Button(.finishSession) {
                finishAlert = true
            }
            .fontWeight(.semibold)
        } else if let status = session.current?.status {
            if status.isPending {
                Button(.complete) {
                    Haptics.impact(.medium)

                    advance(.forward) {
                        session.completeAndAdvance()
                    }
                }
                .fontWeight(.semibold)
                .tint(.green)
            } else {
                Button(status.title, systemImage: status.pictogram.icon) {
                    // Already resolved and always disabled.
                }
                .fontWeight(.semibold)
                .disabled(true)
            }
        }
    }

    @ViewBuilder
    private var secondaryAction: some View {
        if let status = session.current?.status {
            if status.isPending {
                Button(.skipExercise) {
                    advance(.forward) {
                        session.skipAndAdvance()
                    }
                }
            } else {
                Button(.undo) {
                    session.undoStatusChange()
                }
            }
        }
    }

    private func advance(_ direction: SlideDirection, _ action: () -> Void) {
        self.direction = direction
        action()
    }

    private func finish() {
        session.finish()
        Haptics.notification(.success)
        dismiss()
    }

    private func cancel() {
        session.cancel()
        dismiss()
    }
}

#Preview {
    NavigationStack {
        SessionPlayerScreen(session: Samples.session)
    }
    .sampleData()
}
