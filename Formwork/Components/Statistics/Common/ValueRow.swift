//
//  ValueRow.swift
//  Formwork
//
//  Created by Daniel Wolbach on 24.09.26.
//

import FormworkKit
import FormworkUI
import SwiftUI

struct ValueRow: View {
    private let title: String

    private let reading: Reading?

    private let footnote: String?

    @Environment(\.units)
    private var units: Units

    init(title: String, reading: Reading?, footnote: String? = nil) {
        self.title = title
        self.reading = reading
        self.footnote = footnote
    }

    var body: some View {
        LabeledContent {
            Text(verbatim: reading?.formatted(.reading(units: units)) ?? "—")
                .font(.system(.title, design: .rounded, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        } label: {
            Text(title)
                .font(.headline)

            if let footnote {
                Text(footnote)
            }
        }
        .labeledContentStyle(.row)
    }
}

#Preview {
    GroupBox {
        ValueRow(title: PersonalBest.title, reading: .weight(kilograms: 100), footnote: String(localized: .fieldRecentSubtitle(days: History.recentDays)))
    }
    .groupBoxStyle(.card)
    .padding()
}
