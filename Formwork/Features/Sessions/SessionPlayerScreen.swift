//
//  SessionPlayerScreen.swift
//  Formwork
//
//  Created by Daniel Wolbach on 21.09.26.
//

import FormworkKit
import FormworkUI
import SwiftUI

struct SessionPlayerScreen: View {
    private let session: Session

    @Environment(\.dismiss)
    private var dismiss: DismissAction

    @State
    private var finishAlert: Bool = false

    @State
    private var discardAlert: Bool = false

    @State
    private var navigator: SessionNavigator

    @State
    private var sheet: Sheet? = nil

    @State
    private var completions: Int = 0

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
                        .frame(maxWidth: .infinity)
                        .transition(.blurReplace)
                }
            }
        }
        .contentMargins(.bottom, .sections, for: .scrollContent)
        .scrollDisabled(session.isActive)
        .animation(.smooth, value: session.isActive)
        .navigationBarTitleDisplayMode(.inline)
        .sensoryFeedback(.impact(weight: .medium), trigger: completions)
        .sensoryFeedback(.success, trigger: session.isActive) { _, new in !new }
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
            sheet
        }
        .alert(.alertFinishSessionTitle, isPresented: $finishAlert) {
            Button(.cancel) {
                // Works automatically.
            }

            Button(.finishSession) {
                finish()
            }
        } message: {
            Text(.alertFinishSessionMessage)
        }
        .alert(.alertDiscardSessionTitle, isPresented: $discardAlert) {
            Button(.cancel) {
                // Works automatically.
            }

            Button(.discardSession) {
                discard()
            }
        } message: {
            Text(.alertDiscardSessionMessage)
        }
    }

    private var controls: some View {
        VStack(spacing: .sections) {
            HStack(spacing: 24) {
                stepButton(.backward, isEnabled: session.previousEntry != nil) {
                    navigator.backward()
                }

                primaryAction
                    .fontWeight(.semibold)
                    .buttonStyle(.glassProminent)
                    .labelStyle(.fixedTitleAndIcon)

                stepButton(.forward, isEnabled: session.nextEntry != nil) {
                    navigator.forward()
                }
            }
            .controlSize(.large)

            HStack(spacing: .items) {
                Button(.guide) {
                    if let exercise = session.currentEntry?.exercise {
                        sheet = .exerciseGuide(exercise)
                    }
                }
                .disabled(session.currentEntry?.exercise == nil)
                .labelStyle(.fixedIconOnly)
                .buttonBorderShape(.circle)

                secondaryAction
                    .frame(maxWidth: .infinity)
                    .labelStyle(.fixedTitleAndIcon)

                Button(.progress) {
                    sheet = .sessionProgress(session)
                }
                .labelStyle(.fixedIconOnly)
                .buttonBorderShape(.circle)
            }
            .buttonStyle(.card)
            .foregroundStyle(.secondary)
            .controlSize(.small)
        }
        .padding(.horizontal, 32)
    }

    private var primaryAction: some View {
        Group {
            if session.isComplete {
                Button(.finishSession) {
                    finishAlert = true
                }
            } else if let status = session.currentEntry?.status {
                Button(.complete) {
                    completions += 1
                    navigator.complete()
                }
                .tint(.green)
                .disabled(!status.isPending)
            }
        }
        .frame(minWidth: 132 + 48)
    }

    @ViewBuilder
    private var secondaryAction: some View {
        if let entry = session.currentEntry {
            if entry.status.isPending, entry.isAddedWithoutWorkout {
                Button(.remove) {
                    navigator.remove()
                }
            } else if entry.status.isPending {
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

    private func stepButton(_ descriptor: Action, isEnabled: Bool, action: @escaping () -> Void) -> some View {
        Button(descriptor, action: action)
            .font(.title2)
            .foregroundStyle(.secondary)
            .buttonStyle(.plain)
            .labelStyle(.fixedIconOnly)
            .disabled(!isEnabled)
    }

    private func finish() {
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
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 64) {
                // The exercise's categories rather than the entry's target, which the editor below shows.
                PictogramHeader(
                    entry.pictogram,
                    title: entry.title,
                    subtitle: entry.exercise?.categories.formatted(.exerciseCategories),
                    badge: entry.status.isPending ? nil : entry.status.pictogram
                )

                ExerciseTargetEditor(target: $entry.target)
            }

            Spacer()

            Spacer()
        }
        .accessibilityValue(entry.status.title)
    }
}

#Preview {
    NavigationRoot {
        SessionPlayerScreen(Samples.activeSession)
    }
    .sampleData()
}
