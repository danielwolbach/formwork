//
//  ValueColumn.swift
//  Formwork
//
//  Created by Daniel Wolbach on 02.10.26.
//

import FormworkKit
import FormworkUI
import SwiftUI

struct ValueColumn: View {
    private let title: String

    private let reading: Reading?

    private let footnote: String

    @Environment(\.units)
    private var units: Units

    init(title: String, reading: Reading?, footnote: String) {
        self.title = title
        self.reading = reading
        self.footnote = footnote
    }

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)

            Text(verbatim: reading?.formatted(.reading(units: units)) ?? "—")
                .font(.system(.largeTitle, design: .rounded, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.5)

            Text(footnote)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    GroupBox {
        HStack {
            ValueColumn(title: String(localized: .fieldBeforeTitle), reading: .duration(seconds: 2700), footnote: String(localized: .fieldBeforeSubtitle(days: History.baselineDays)))

            ValueColumn(title: String(localized: .fieldRecentTitle), reading: nil, footnote: String(localized: .fieldRecentSubtitle(days: History.recentDays)))
        }
    }
    .groupBoxStyle(.card)
    .padding()
}
