//
//  SectionView.swift
//  Formwork
//
//  Created by Daniel Wolbach on 20.09.26.
//

import FormworkKit
import SwiftUI

struct SectionView<Content: View, Accessory: View>: View {
    private let title: LocalizedStringResource
    private let subtitle: String?
    private let content: Content
    private let accessory: Accessory

    init(_ title: LocalizedStringResource, subtitle: String? = nil, @ViewBuilder content: () -> Content, @ViewBuilder accessory: () -> Accessory) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
        self.accessory = accessory()
    }

    var body: some View {
        VStack(spacing: 8) {
            header
            content
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .lineLimit(1)
                    .font(.headline)

                if let subtitle {
                    Text(subtitle)
                        .lineLimit(1)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            accessory
        }
        // Optical alignment: the heading sits flush with the rounded cards and rows below it.
        .padding(.horizontal, 2)
    }
}

extension SectionView where Accessory == EmptyView {
    init(_ title: LocalizedStringResource, subtitle: String? = nil, @ViewBuilder content: () -> Content) {
        self.init(title, subtitle: subtitle, content: content) {
            EmptyView()
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 32) {
            SectionView(.screenSessionsTitle, subtitle: String(localized: Session.countTitle(34))) {
                StatisticCard(title: "Card", value: "Content", pictogram: .workout)
            } accessory: {
                Button(.viewAll) {}
                    .labelStyle(.fixedTitleAndIcon)
                    .buttonStyle(.glass)
            }

            SectionView(.screenStatisticsTitle) {
                StatisticCard(title: "Card", value: "No accessory", pictogram: .streak)
            }
        }
        .padding(.horizontal)
    }
}
