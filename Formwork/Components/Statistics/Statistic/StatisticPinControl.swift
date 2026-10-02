//
//  StatisticPinControl.swift
//  Formwork
//
//  Created by Daniel Wolbach on 02.10.26.
//

import FormworkKit
import FormworkUI
import SwiftData
import SwiftUI

struct StatisticPinControl<Content: View>: View {
    private let kind: StatisticKind

    private let subject: History.Subject

    private let content: (Binding<Bool>) -> Content

    @Environment(\.modelContext)
    private var modelContext: ModelContext

    @Query
    private var pins: [StatisticPin]

    init(_ kind: StatisticKind, of subject: History.Subject, @ViewBuilder content: @escaping (_ isPinned: Binding<Bool>) -> Content) {
        self.kind = kind
        self.subject = subject
        self.content = content
    }

    var body: some View {
        let pin = pins.first { $0.kind == kind && $0.subject == subject }

        content(Binding {
            pin != nil
        } set: { isPinned in
            if let pin, !isPinned {
                modelContext.delete(pin)
            } else if pin == nil, isPinned {
                try? StatisticPin.append(kind, of: subject, into: modelContext)
            }
        })
    }
}

#Preview {
    StatisticPinControl(.weekStreak, of: .all) { isPinned in
        Toggle(.pin, isOn: isPinned)
            .toggleStyle(.button)
    }
    .sampleData()
}
