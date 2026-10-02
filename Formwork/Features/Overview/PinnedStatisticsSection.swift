//
//  PinnedStatisticsSection.swift
//  Formwork
//
//  Created by Daniel Wolbach on 02.10.26.
//

import FormworkKit
import FormworkUI
import SwiftData
import SwiftUI

struct PinnedStatisticsSection: View {
    /// A copy, not the pin: unpinning from the sheet deletes the pin while the sheet still shows it.
    private struct Detail: Identifiable {
        let id = UUID()

        let kind: StatisticKind

        let history: History
    }

    @Environment(\.modelContext)
    private var modelContext: ModelContext

    @Query(sort: \StatisticPin.order, animation: .snappy)
    private var pins: [StatisticPin]

    @Query(Session.finishedDescriptor)
    private var sessions: [Session]

    @State
    private var detail: Detail? = nil

    var body: some View {
        let visible = pins.filter { !$0.isArchived }

        // Stays while the sheet is up, so unpinning the last statistic from it doesn't dismiss it.
        if !visible.isEmpty || detail != nil {
            FlowLayout(alignment: .leading) {
                ForEach(visible) { pin in
                    chip(for: pin, in: visible)
                        .transition(.opacity)
                }
            }
            .sheet(item: $detail) { detail in
                NavigationStack {
                    StatisticSheet(detail.kind, of: detail.history)
                }
                .presentationDetents([.medium, .large])
            }
        }
    }

    private func chip(for pin: StatisticPin, in visible: [StatisticPin]) -> some View {
        let history = History(pin.subject, among: sessions)

        return Button {
            // A tap above an open sheet also reaches the chips behind it, so it may only close the sheet.
            guard detail == nil else {
                return
            }

            detail = Detail(kind: pin.kind, history: history)
        } label: {
            StatisticChip(pin.kind, of: history)
        }
        .buttonStyle(.plain)
        .contextMenu {
            Section {
                if pin != visible.first {
                    Button(.moveBackward) {
                        pin.move(by: -1, among: visible)
                    }
                }

                if pin != visible.last {
                    Button(.moveForward) {
                        pin.move(by: 1, among: visible)
                    }
                }
            }

            Button(.unpin) {
                modelContext.delete(pin)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            ContentStack {
                PinnedStatisticsSection()
            }
        }
    }
    .sampleData()
}
