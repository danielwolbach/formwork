//
//  SessionMiniPlayer.swift
//  Formwork
//
//  Created by Daniel Wolbach on 05.09.26.
//

import FormworkKit
import FormworkUI
import SwiftData
import SwiftUI

struct SessionMiniPlayer: View {
    private let session: Session

    private let namespace: Namespace.ID

    @Environment(\.presentSession)
    private var presentSession: PresentSessionAction

    @Environment(\.units)
    private var units: Units

    @State
    private var navigator: SessionNavigator

    init(_ session: Session, namespace: Namespace.ID) {
        self.session = session
        self.namespace = namespace
        self._navigator = State(initialValue: SessionNavigator(session: session))
    }

    var body: some View {
        // Replacing a session deletes and saves it while this view is still on screen, and its entries can't be read then.
        if !session.isDeleted, session.modelContext != nil {
            content
        }
    }

    private var content: some View {
        HStack(spacing: 0) {
            SessionEntryPager(navigator: navigator) { entry in
                row(for: entry)
            }
            .mask {
                HStack(spacing: 0) {
                    LinearGradient(colors: [.clear, .black], startPoint: .leading, endPoint: .trailing).frame(width: 16)

                    Rectangle()

                    LinearGradient(colors: [.black, .clear], startPoint: .leading, endPoint: .trailing).frame(width: 16)
                }
            }

            sessionProgress
                .padding(.trailing)

            statusAction
                .padding(.trailing)
        }
        .matchedTransitionSource(id: session.id, in: namespace)
        .sensoryFeedback(trigger: session.resolvedCount) { old, new in
            new > old ? .impact(weight: .medium) : nil
        }
        .onTapGesture {
            presentSession(session)
        }
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
        switch session.currentEntry?.status {
        case .pending:
            Button(.complete) {
                navigator.complete()
            }
            .fontWeight(.bold)
            .tint(.green)
            .labelStyle(.fixedIconOnly)
            .buttonStyle(.glassProminent)
            .buttonBorderShape(.circle)

        case .completed, .skipped:
            Button(.undo) {
                navigator.undo()
            }
            .labelStyle(.fixedIconOnly)
            .buttonStyle(.glass)
            .buttonBorderShape(.circle)

        case nil:
            EmptyView()
        }
    }

    private var sessionProgress: some View {
        Text(verbatim: "\(session.resolvedCount) / \((session.entries ?? []).count)")
            .font(.caption2)
            .monospacedDigit()
            .foregroundStyle(.secondary)
            .contentTransition(.numericText(value: Double(session.resolvedCount)))
            .accessibilityLabel(Text(.sessionProgressLabel(resolved: session.resolvedCount, total: (session.entries ?? []).count)))
    }

    @ViewBuilder
    private func row(for entry: SessionEntry) -> some View {
        let badge = entry.status.isPending ? nil : entry.status.pictogram

        HStack {
            PictogramView(entry.pictogram, badge: badge)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 0) {
                Text(entry.title)
                    .font(.caption)

                Text(entry.target.formatted(.exerciseTarget(units: units)))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.horizontal)
        .contentShape(.rect)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityValue(entry.status.title)
        .accessibilityAction {
            presentSession(session)
        }
    }
}

#Preview {
    @Previewable @Namespace
    var namespace

    TabView {
        // Empty.
    }
    .tabViewBottomAccessory {
        SessionMiniPlayer(Samples.activeSession, namespace: namespace)
    }
    .sampleData()
}
