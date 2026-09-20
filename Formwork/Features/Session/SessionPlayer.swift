//
//  SessionPlayer.swift
//  Formwork
//
//  Created by Daniel Wolbach on 05.09.26.
//

import FormworkKit
import SwiftUI

struct SessionPlayer: View {
    @State private var navigator: SessionNavigator

    let session: Session
    let requestFinish: () -> Void

    init(session: Session, requestFinish: @escaping () -> Void) {
        self.session = session
        self.requestFinish = requestFinish
        _navigator = State(initialValue: SessionNavigator(session: session))
    }

    var body: some View {
        SessionEntryPager(navigator: navigator) { entry in
            SessionEntryPage(entry: entry)
        }
        .safeAreaBar(edge: .bottom) {
            controls
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
            Button(.finishSession, action: requestFinish)
                .fontWeight(.semibold)
        } else if let status = session.current?.status {
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
        SessionPlayer(session: Samples.sessions.first!) {}
    }
    .sampleData()
}
