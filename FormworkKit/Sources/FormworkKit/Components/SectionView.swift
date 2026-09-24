//
//  SectionView.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 20.09.26.
//

import SwiftUI

/// A heading with an optional subtitle and accessory over its content. The heading is inset like a screen's
/// content, so the content brings its own horizontal padding.
public struct SectionView<Content: View, Accessory: View>: View {
    private let title: String

    private let subtitle: String?

    private let content: Content

    private let accessory: Accessory

    public init(_ title: String, subtitle: String? = nil, @ViewBuilder content: () -> Content, @ViewBuilder accessory: () -> Accessory) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
        self.accessory = accessory()
    }

    public var body: some View {
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
        .padding(.horizontal)
        // Optical alignment: the heading sits flush with the rounded cards and rows below it.
        .padding(.horizontal, 2)
    }
}

extension SectionView {
    public init(_ title: LocalizedStringResource, subtitle: String? = nil, @ViewBuilder content: () -> Content, @ViewBuilder accessory: () -> Accessory) {
        self.init(String(localized: title), subtitle: subtitle, content: content, accessory: accessory)
    }
}

extension SectionView where Accessory == EmptyView {
    public init(_ title: String, subtitle: String? = nil, @ViewBuilder content: () -> Content) {
        self.init(title, subtitle: subtitle, content: content) {
            EmptyView()
        }
    }

    public init(_ title: LocalizedStringResource, subtitle: String? = nil, @ViewBuilder content: () -> Content) {
        self.init(String(localized: title), subtitle: subtitle, content: content)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 32) {
            SectionView(.statisticRecentTitle, subtitle: String(localized: Session.countTitle(34))) {
                ValueCard(Samples.weekStreak)
                    .padding(.horizontal)
            } accessory: {
                Button(.viewAll) {}
                    .labelStyle(.fixedTitleAndIcon)
                    .buttonStyle(.glass)
            }

            SectionView(String(2026)) {
                ValueCard(Samples.weeklySessions)
                    .padding(.horizontal)
            }
        }
    }
}
