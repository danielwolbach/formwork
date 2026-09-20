//
//  SessionScreen.swift
//  Formwork
//
//  Created by Daniel Wolbach on 20.09.26.
//

import FormworkKit
import SwiftData
import SwiftUI

struct SessionScreen: View {
    @Environment(\.modelContext) private var modelContext: ModelContext
    @Environment(\.dismiss) private var dismiss: DismissAction
    @State private var finishAlert = false
    @State private var cancelAlert = false
    @State private var deleteAlert = false

    let session: Session

    var body: some View {
        ZStack {
            if session.isActive {
                SessionPlayer(session: session) {
                    finishAlert = true
                }
                .transition(.blurReplace)
            } else {
                summary.transition(.blurReplace)
            }
        }
        .toolbar {
            toolbarContent
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
        .alert(.alertSessionDeleteTitle, isPresented: $deleteAlert) {
            Button(.delete) {
                delete()
            }

            Button(.cancel) {}
        } message: {
            Text(.alertSessionDeleteMessage)
        }
    }

    private var summary: some View {
        let sessionSummary = session.summary()

        return ScrollView {
            VStack(spacing: 32) {
                PictogramHeader(session)

                LazyVGrid(columns: GridItem.ntile(n: 2, spacing: 8), spacing: 8) {
                    StatisticCard(sessionSummary.duration)
                    StatisticCard(sessionSummary.endTime)
                    StatisticCard(sessionSummary.skipRate)
                    StatisticCard(sessionSummary.medianExerciseDuration)
                    StatisticCard(sessionSummary.completedExercises)
                    StatisticCard(sessionSummary.totalVolume)
                }
                .padding(.horizontal)

                LazyVStack(spacing: 0) {
                    ForEach(session.orderedEntries) { entry in
                        SessionEntryRow(entry: entry, badge: badge(for: entry), details: details(for: entry))
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                    }
                }
            }
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        if session.isActive {
            ToolbarItem(placement: .principal) {
                SessionStatus(session: session)
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
            ToolbarItem(placement: .topBarTrailing) {
                Menu(.more) {
                    Section {
                        Button(.delete) {
                            deleteAlert = true
                        }
                    }
                }
            }
        }
    }

    private func badge(for entry: SessionEntry) -> Pictogram {
        entry.isPersonalBest ? .recordBadge : entry.status.pictogram
    }

    private func details(for entry: SessionEntry) -> [(pictogram: Pictogram, text: String)] {
        var details: [(pictogram: Pictogram, text: String)] = []

        if let resolved = entry.status.resolved {
            details.append((.time, resolved.formatted(session.wallClockTime())))
        }

        if let elapsed = entry.elapsed {
            details.append((.pace, Duration.seconds(elapsed).formatted(.exerciseDuration)))
        }

        if let change = entry.change {
            details.append((change.difference > 0 ? .increase : .decrease, change.magnitude))
        }

        return details
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

    private func delete() {
        modelContext.delete(session)
        dismiss()
    }
}

private struct SessionEntryRow: View {
    @State private var isExpanded = false

    let entry: SessionEntry
    let badge: Pictogram
    let details: [(pictogram: Pictogram, text: String)]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                withAnimation(.snappy) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    PictogramRow(entry, badge: badge)

                    if !details.isEmpty {
                        Image(systemName: "chevron.down")
                            .foregroundStyle(.tertiary)
                            .scaleEffect(y: isExpanded ? -1 : 1)
                    }
                }
            }
            .buttonStyle(.plain)

            if isExpanded, !details.isEmpty {
                FlowLayout(alignment: .leading) {
                    ForEach(details, id: \.pictogram) { detail in
                        Label(detail.text, systemImage: detail.pictogram.image)
                            .monospacedDigit()
                            .labelStyle(.chip(tint: detail.pictogram.color))
                    }
                }
                .padding(.leading, 64 + 8)
            }
        }
        .sensoryFeedback(.selection, trigger: isExpanded)
    }
}

#Preview("Running") {
    NavigationStack {
        SessionScreen(session: Samples.sessions.first!)
    }
    .sampleData()
}

#Preview("Ended") {
    let sessions = (try? Samples.container.mainContext.fetch(Session.finishedDescriptor)) ?? []

    NavigationStack {
        if let session = sessions.first {
            SessionScreen(session: session)
        }
    }
    .sampleData()
}
