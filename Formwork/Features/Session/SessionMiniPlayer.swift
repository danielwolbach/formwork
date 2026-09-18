//
//  SessionMiniPlayer.swift
//  Formwork
//
//  Created by Daniel Wolbach on 05.09.26.
//

import FormworkKit
import SwiftData
import SwiftUI

struct SessionMiniPlayer: View {
    @Environment(\.presentSession) private var presentSession: PresentSessionAction
    @State private var navigator: SessionNavigator

    let session: Session
    let namespace: Namespace.ID

    init(session: Session, namespace: Namespace.ID) {
        self.session = session
        self.namespace = namespace
        _navigator = State(initialValue: SessionNavigator(session: session))
    }

    var body: some View {
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
        .matchedTransitionSource(id: session.persistentModelID, in: namespace)
    }

    @ViewBuilder
    private func row(for entry: SessionEntry) -> some View {
        let badge = entry.status.isPending ? nil : entry.status.pictogram

        HStack {
            PictogramView(pictogram: entry.pictogram, badge: badge)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 0) {
                Text(entry.title)
                    .font(.caption)

                if let subtitle = entry.subtitle {
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding(.horizontal)
        .contentShape(.rect)
        .accessibilityAddTraits(.isButton)
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
        switch session.current?.status {
        case .pending:
            Button(.complete, action: completeCurrentEntry)
                .fontWeight(.bold)
                .tint(.green)
                .labelStyle(.fixedIconOnly)
                .buttonStyle(.glassProminent)
                .buttonBorderShape(.circle)

        case .completed, .skipped:
            Button(.undo, action: navigator.undo)
                .labelStyle(.fixedIconOnly)
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)

        case nil:
            EmptyView()
        }
    }

    private var sessionProgress: some View {
        Text(verbatim: "\(session.resolvedCount) / \(session.entries.count)")
            .font(.caption2)
            .monospacedDigit()
            .foregroundStyle(.secondary)
            .contentTransition(.numericText(value: Double(session.resolvedCount)))
    }

    private func completeCurrentEntry() {
        Haptics.impact(.medium)
        navigator.complete()
    }
}

#Preview {
    @Previewable @Namespace var namespace

    TabView {
        // Empty.
    }
    .tabViewBottomAccessory {
        SessionMiniPlayer(session: Samples.sessions.first!, namespace: namespace)
    }
    .sampleData()
}
