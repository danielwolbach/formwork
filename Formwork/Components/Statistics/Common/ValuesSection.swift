//
//  ValuesSection.swift
//  Formwork
//
//  Created by Daniel Wolbach on 24.09.26.
//

import FormworkKit
import FormworkUI
import SwiftUI

struct ValuesSection: View {
    private let overall: String?

    private let recent: String?

    private let baseline: String?

    private let direction: Direction?

    init(overall: String?, recent: String?, baseline: String? = nil, direction: Direction? = nil) {
        self.overall = overall
        self.recent = recent
        self.baseline = baseline
        self.direction = direction
    }

    var body: some View {
        GroupBox {
            VStack(spacing: .groups) {
                if let baseline, let direction {
                    HStack(spacing: .items) {
                        column(title: String(localized: .fieldBeforeTitle), value: baseline, footnote: String(localized: .fieldBeforeSubtitle(days: History.baselineDays)))

                        Image(systemName: direction.image)
                            .font(.title.weight(.semibold))
                            .foregroundStyle(.tint)
                            .frame(maxWidth: .infinity)

                        column(title: String(localized: .fieldRecentTitle), value: recent, footnote: String(localized: .fieldRecentSubtitle(days: History.recentDays)))
                    }
                } else {
                    ValueRow(title: String(localized: .fieldRecentTitle), value: recent, footnote: String(localized: .fieldRecentSubtitle(days: History.recentDays)))
                }

                Divider()

                ValueRow(title: .init(localized: .fieldOverallTitle), value: overall)
            }
        }
        .groupBoxStyle(.card)
    }

    private func column(title: String, value: String?, footnote: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)

            Text(verbatim: value ?? "—")
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
