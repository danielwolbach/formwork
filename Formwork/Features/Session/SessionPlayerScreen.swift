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
    @State private var navigator: SessionNavigator
    @State private var finishAlert: Bool = false
    @State private var cancelAlert: Bool = false

    let session: Session

    init(session: Session) {
        self.session = session
        _navigator = State(initialValue: SessionNavigator(session: session))
    }

    var body: some View {
        SessionEntryPager(navigator: navigator) { entry in
            SessionEntryPage(entry: entry)
        }
        .safeAreaBar(edge: .bottom) {
            controls
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                SessionStatus(session: session)
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
                        Button(.discardSession) {
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
                .disabled(session.previous == nil)
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
                .labelStyle(.fixedIconOnly)

                primaryAction
                    .buttonStyle(.glassProminent)
                    .labelStyle(.fixedTitleAndIcon)

                Button(.forward) {
                    navigator.forward()
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
                    navigator.complete()
                }
                .fontWeight(.semibold)
                .tint(.green)
            } else {
                Button(status.title, systemImage: status.pictogram.image) {
                    // Already resolved and therefore always disabled.
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
        session.finish()
        Haptics.notification(.success)
        dismiss()
    }

    private func cancel() {
        session.cancel()
        dismiss()
    }
}

private struct SessionEntryPage: View {
    @Bindable var entry: SessionEntry

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
