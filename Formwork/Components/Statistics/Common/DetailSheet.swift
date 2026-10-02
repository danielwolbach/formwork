//
//  DetailSheet.swift
//  Formwork
//
//  Created by Daniel Wolbach on 02.10.26.
//

import FormworkKit
import FormworkUI
import SwiftUI

struct DetailSheet<Content: View, Accessory: View>: View {
    private let pictogram: Pictogram

    private let title: String

    private let subtitle: String?

    private let info: String

    @ViewBuilder
    private let content: Content

    @ViewBuilder
    private let accessory: Accessory

    init(
        _ pictogram: Pictogram,
        title: String,
        subtitle: String?,
        info: String,
        @ViewBuilder content: () -> Content,
        @ViewBuilder accessory: () -> Accessory
    ) {
        self.pictogram = pictogram
        self.title = title
        self.subtitle = subtitle
        self.info = info
        self.content = content()
        self.accessory = accessory()
    }

    var body: some View {
        ScrollView {
            ContentStack(spacing: .groups) {
                HStack {
                    PictogramRow(pictogram, title: title, subtitle: subtitle)

                    accessory
                }

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

extension DetailSheet where Accessory == EmptyView {
    init(_ pictogram: Pictogram, title: String, subtitle: String?, info: String, @ViewBuilder content: () -> Content) {
        self.init(pictogram, title: title, subtitle: subtitle, info: info, content: content, accessory: { EmptyView() })
    }
}

#Preview {
    NavigationStack {}
        .sheet(isPresented: .constant(true)) {
            NavigationStack {
                DetailSheet(WeekStreak.pictogram, title: WeekStreak.title, subtitle: nil, info: WeekStreak.info) {
                    GroupBox {
                        ValueRow(title: WeekStreak.title, reading: .count(3))
                    }
                    .groupBoxStyle(.card)
                }
            }
            .presentationDetents([.medium, .large])
        }
}
