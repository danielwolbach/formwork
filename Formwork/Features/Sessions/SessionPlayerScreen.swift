//
//  SessionPlayerScreen.swift
//  Formwork
//
//  Created by Daniel Wolbach on 21.09.26.
//

import FormworkKit
import SwiftUI

struct SessionPlayerScreen: View {
    private let session: Session

    @Environment(\.dismiss)
    private var dismiss: DismissAction

    @State
    private var finishAlert = false

    @State
    private var discardAlert = false

    @State
    private var navigator: SessionNavigator

    @State
    private var sheet: Sheet? = nil

    init(_ session: Session) {
        self.session = session
        self._navigator = State(initialValue: SessionNavigator(session: session))
    }

    var body: some View {
        // The ScrollView stays the permanent root because the navigation bar and scroll
        // edge effects only detect a root-level ScrollView. Transitions need a container,
        // and one above the ScrollView would hide it, so the swap happens in a ZStack
        // inside it. Both branches are pinned to full width so the ZStack doesn't
        // resize and slide the content mid-transition.
        ScrollView {
            ZStack {
                if session.isActive {
                    SessionEntryPager(navigator: navigator) { entry in
                        SessionEntryPage(entry)
                    }
                    .containerRelativeFrame([.horizontal, .vertical], alignment: .top)
                    .transition(.blurReplace)
                } else {
                    SessionRecap(session)
                        .transition(.blurReplace)
                        .frame(maxWidth: .infinity)
                        .transition(.blurReplace)
                }
            }
        }
        .scrollDisabled(session.isActive)
        .animation(.smooth, value: session.isActive)
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaBar(edge: .bottom) {
            if session.isActive {
                controls
            }
        }
        .toolbar {
            // Declared once and faded rather than moved between the branches below: the
            // principal item is the bar's own title view, so removing it makes the bar
            // re-lay-out that area on its own clock, out of step with the transition,
            // which causes a buggy toolbar transition. Might be fixed by a future
            // SwiftUI version.
            ToolbarItem(placement: .principal) {
                SessionStatus(session)
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
                                discardAlert = true
                            }
                        }
                    }
                }
            } else {
                ToolbarItem(placement: .topBarLeading) {
                    SessionShareLink(session)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(.confirm) {
                        dismiss()
                    }
                }
            }
        }
        .sheet(item: $sheet) { sheet in
            NavigationStack {
                sheet
            }
        }
        .alert(.placeholder, isPresented: $finishAlert) {
            Button(.cancel) {
                // Works automatically.
            }

            Button(.finishSession) {
                finish()
            }
        } message: {
            Text(.placeholder)
        }
        .alert(.placeholder, isPresented: $discardAlert) {
            Button(.cancel) {
                // Works automatically.
            }

            Button(.discardSession) {
                discard()
            }
        } message: {
            Text(.placeholder)
        }
    }

    private var controls: some View {
        VStack(spacing: 32) {
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
                        sheet = .exerciseGuide(exercise)
                    }
                }
                .disabled(session.currentEntry?.exercise == nil)
                .frame(maxWidth: .infinity)

                secondaryAction
                    .frame(maxWidth: .infinity)

                Button(.queue) {
                    // TODO:
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

    private func discard() {
        session.discard()
        dismiss()
    }
}

private struct SessionEntryPage: View {
    @Bindable
    private var entry: SessionEntry

    init(_ entry: SessionEntry) {
        self.entry = entry
    }

    var body: some View {
        VStack(spacing: 32) {
            // The exercise's categories rather than the entry's target, which the editor below shows.
            DisplayableHeader(
                pictogram: entry.pictogram,
                title: entry.title,
                subtitle: entry.exercise?.subtitle,
                badge: entry.status.isPending ? nil : entry.status.pictogram
            )

            ExerciseTargetEditor(target: $entry.target)

            Spacer()
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

#Preview {
    NavigationStack {
        SessionPlayerScreen(Samples.activeSession)
    }
    .sampleData()
}
