//
//  StatisticChips.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.10.26.
//

import Flow
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

        HFlow {
            ForEach(Self.kinds) { kind in
                Button {
                    guard selection == nil else {
                        return
                    }

                    selection = kind
                } label: {
                    StatisticChip(kind, of: history)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(kind.definition.title)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .sheet(item: $selection) { kind in
            NavigationRoot {
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

        Label(text, systemImage: pictogram.image)
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
    NavigationRoot {
        ScrollView {
            ContentStack {
                StatisticChips()
            }
        }
    }
    .sampleData()
}
