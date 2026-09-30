//
//  StatisticSheet.swift
//  Formwork
//
//  Created by Daniel Wolbach on 24.09.26.
//

import FormworkKit
import FormworkUI
import SwiftUI

struct StatisticSheet<S: Statistic, Content: View>: View {
    private let pictogram: Pictogram

    private let title: String

    private let subtitle: String?

    private let info: String

    @ViewBuilder
    private let content: Content

    init(_ statistic: S, history: History, @ViewBuilder content: () -> Content) {
        self.pictogram = statistic.pictogram
        self.title = statistic.title
        self.subtitle = history.subject.title
        self.info = S.info
        self.content = content()
    }

    var body: some View {
        ScrollView {
            ContentStack(spacing: .groups) {
                PictogramRow(pictogram, title: title, subtitle: subtitle)

                content

                SectionView(.init(localized: .fieldInfoTitle)) {
                    GroupBox {
                        Text(info)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .groupBoxStyle(.card)
                }
            }
        }
        .contentMargins(.vertical, .sections, for: .scrollContent)
        .presentationDragIndicator(.visible)
    }
}
