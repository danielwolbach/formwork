//
//  StatisticChips.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.10.26.
//

import FormworkKit
import FormworkUI
import SwiftData
import SwiftUI

struct StatisticChips: View {
    private static let kinds: [StatisticKind] = [.weekStreak, .lastCompleted]

    @Query(Session.finishedDescriptor)
    private var sessions: [Session]

    @State
    private var selection: StatisticKind? = nil

    var body: some View {
        let history = History(.all, among: sessions)

        FlowLayout(alignment: .leading) {
            ForEach(Self.kinds) { kind in
                Button {
                    // A tap above an open sheet also reaches the chips behind it, so it may only close the sheet.
                    guard selection == nil else {
                        return
                    }

                    selection = kind
                } label: {
                    StatisticChip(kind, of: history)
                }
                .buttonStyle(.plain)
            }
        }
        .sheet(item: $selection) { kind in
            NavigationStack {
                StatisticSheet(kind, of: history)
            }
            .presentationDetents([.medium, .large])
        }
    }
}

private struct StatisticChip: View {
    private let kind: StatisticKind

    private let history: History

    @Environment(\.units)
    private var units: Units

    init(_ kind: StatisticKind, of history: History) {
        self.kind = kind
        self.history = history
    }

    var body: some View {
        let pictogram = kind.definition.pictogram

        Label {
            Text(verbatim: text)
        } icon: {
            Image(systemName: pictogram.image)
        }
        .labelStyle(.chip(tint: pictogram.color))
    }

    private var text: String {
        guard case let .reading(reading, _) = kind.summary(of: history) else {
            return kind.definition.title
        }

        return reading?.formatted(.reading(units: units)) ?? "—"
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            ContentStack {
                StatisticChips()
            }
        }
    }
    .sampleData()
}
