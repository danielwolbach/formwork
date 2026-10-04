//
//  DetailSheet.swift
//  Formwork
//
//  Created by Daniel Wolbach on 02.10.26.
//

import FormworkKit
import FormworkUI
import SwiftUI

struct DetailSheet<Content: View>: View {
    private let pictogram: Pictogram

    private let title: String

    private let subtitle: String?

    private let info: String

    @ViewBuilder
    private let content: Content

    init(_ pictogram: Pictogram, title: String, subtitle: String?, info: String, @ViewBuilder content: () -> Content) {
        self.pictogram = pictogram
        self.title = title
        self.subtitle = subtitle
        self.info = info
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
        .tint(pictogram.color)
    }
}

#Preview {
    NavigationStack {}
        .sheet(isPresented: .constant(true)) {
            NavigationStack {
                let definition = StatisticKind.weekStreak.definition

                DetailSheet(definition.pictogram, title: definition.title, subtitle: nil, info: definition.info) {
                    GroupBox {
                        ValueRow(title: definition.title, reading: .count(3))
                    }
                    .groupBoxStyle(.card)
                }
            }
            .presentationDetents([.medium, .large])
        }
}
