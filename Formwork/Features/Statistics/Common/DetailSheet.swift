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

    init(_ item: some Describable, subtitle: String?, @ViewBuilder content: () -> Content) {
        self.pictogram = item.pictogram
        self.title = item.title
        self.subtitle = subtitle
        self.info = item.info
        self.content = content()
    }

    var body: some View {
        ScrollView {
            ContentStack {
                PictogramRow(pictogram, title: title, subtitle: subtitle)
                    // Serves as a header for the row below.
                    .padding(.bottom, -1 * .groups)

                content

                SectionView(.fieldInfoTitle) {
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
    NavigationRoot {}
        .sheet(isPresented: .constant(true)) {
            NavigationRoot {
                DetailSheet(Statistic.weekStreak, subtitle: nil) {
                    GroupBox {
                        ValueRow(title: Statistic.weekStreak.title, reading: .count(3))
                    }
                    .groupBoxStyle(.card)
                }
            }
            .presentationDetents([.medium, .large])
        }
}
