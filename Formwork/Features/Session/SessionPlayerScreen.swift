//
//  SessionPlayerScreen.swift
//  Formwork
//
//  Created by Daniel Wolbach on 21.09.26.
//

import FormworkKit
import SwiftUI

struct SessionPlayerScreen: View {
    let session: Session

    @Environment(\.dismiss)
    private var dismiss: DismissAction

    @State
    private var navigator: SessionNavigator

    @State
    private var sheet: Sheet? = nil

    @State
    private var finishAlert = false

    @State
    private var cancelAlert = false

    init(session: Session) {
        self.session = session
        _navigator = State(initialValue: SessionNavigator(session: session))
    }

    var body: some View {
        ZStack {
            if session.isActive {
                SessionEntryPager(navigator: navigator) { entry in
                    SessionEntryPage(entry: entry)
                }
                .safeAreaBar(edge: .bottom) {
                    controls
                }
                .transition(.blurReplace)
            } else {
                ScrollView {
                    SessionRecap(session: session)
                }
                .transition(.blurReplace)
            }
        }
        .toolbar {
            // Declared once and faded rather than moved between the branches below: the
            // principal item is the bar's own title view, so removing it makes the bar
            // re-lay-out that area on its own clock, out of step with the transition,
            // which causes a buggy toolbar transition. Might be fixed by a future
            // SwiftUI version.
            ToolbarItem(placement: .principal) {
                SessionStatus(session: session)
                    .opacity(session.isActive ? 1 : 0)
                    .accessibilityHidden(!session.isActive)
                    .animation(.smooth, value: session.isActive)
            }

            if session.isActive {
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
                            Button(.discardSession) {
                                cancelAlert = true
                            }
                        }
                    }
                }
            } else {
                ToolbarItem(placement: .topBarLeading) {
                    SessionShareLink(session: session)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(.confirm) {
                        dismiss()
                    }
                }
            }
        }
        .sheet(item: $sheet) { $0 }
        .alert(.alertSessionFinishTitle, isPresented: $finishAlert) {
            Button(.finishSession) {
                finish()
            }

            Button(.cancel) {}
        } message: {
            Text(.alertSessionFinishMessage)
        }
        .alert(.alertSessionCancelTitle, isPresented: $cancelAlert) {
            Button(.discardSession) {
                cancel()
            }

            Button(.cancel) {}
        } message: {
            Text(.alertSessionCancelMessage)
        }
    }

    private var controls: some View {
        VStack(spacing: 16) {
            HStack {
                Button(.backward) {
                    navigator.backward()
                }
                .disabled(session.previousEntry == nil)
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
                .labelStyle(.fixedIconOnly)

                primaryAction
                    .buttonStyle(.glassProminent)
                    .labelStyle(.fixedTitleAndIcon)

                Button(.forward) {
                    navigator.forward()
                }
                .disabled(session.nextEntry == nil)
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
                .labelStyle(.fixedIconOnly)
            }
            .controlSize(.large)

            HStack(spacing: 16) {
                Button(.guide) {
                    if let exercise = session.currentEntry?.exercise {
                        sheet = .viewGuide(exercise: exercise)
                    }
                }
                .disabled(session.currentEntry?.exercise == nil)
                .frame(maxWidth: .infinity)

                secondaryAction
                    .frame(maxWidth: .infinity)
                
                Button(.queue) {
                    // TODO
                }
                .frame(maxWidth: .infinity)
            }
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
        } else if let status = session.currentEntry?.status {
            Button(.complete) {
                Haptics.impact(.medium)
                navigator.complete()
            }
            .fontWeight(.semibold)
            .tint(.green)
            .disabled(!status.isPending)
        }
    }

    @ViewBuilder
    private var secondaryAction: some View {
        if let status = session.currentEntry?.status {
            if status.isPending {
                Button(.skip) {
                    navigator.skip()
                }
            } else {
                Button(.undo) {
                    navigator.undo()
                }
            }
        }
    }

    private func finish() {
        Haptics.notification(.success)

        withAnimation(.smooth) {
            session.finish()
        }
    }

    private func cancel() {
        session.cancel()
        dismiss()
    }
}

private struct SessionEntryPage: View {
    @Bindable
    var entry: SessionEntry

    var body: some View {
        let badge = entry.status.isPending ? nil : entry.status.pictogram

        VStack(spacing: 32) {
            // Show the exercise's categories, not the entry's target since
            // the target editor below already shows it.
            PictogramHeader(pictogram: entry.pictogram, title: entry.title, subtitle: entry.exercise?.subtitle, badge: badge)
            ExerciseTargetEditor(target: $entry.target)
            Spacer()
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

#Preview {
    NavigationStack {
        SessionPlayerScreen(session: Samples.sessions.first!)
    }
    .sampleData()
}
