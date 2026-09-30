//
//  SectionView.swift
//  FormworkUI
//
//  Created by Daniel Wolbach on 20.09.26.
//

import SwiftUI

public struct SectionView<Content: View, Accessory: View>: View {
    private let title: String?

    private let subtitle: String?

    private let content: Content

    private let accessory: Accessory

    public init(_ title: String?, subtitle: String? = nil, @ViewBuilder content: () -> Content, @ViewBuilder accessory: () -> Accessory) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
        self.accessory = accessory()
    }

    public var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    if let title {
                        Text(title)
                            .lineLimit(1)
                            .font(.headline)
                    }

                    if let subtitle {
                        Text(subtitle)
                            .lineLimit(1)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer(minLength: 0)

                accessory
            }
            .padding(.horizontal)
            // Optical alignment with rounded cards.
            .padding(.horizontal, 2)

            content
        }
    }
}

extension SectionView where Accessory == EmptyView {
    public init(_ title: String? = nil, subtitle: String? = nil, @ViewBuilder content: () -> Content) {
        self.init(title, subtitle: subtitle, content: content, accessory: { EmptyView() })
    }
}

#Preview {
    SectionView("Title", subtitle: "Subtitle") {
        GroupBox {
            Text("Hello World")
        }
        .padding(.horizontal)
    } accessory: {
        Button("Accessory") {
            // Do nothing.
        }
        .buttonStyle(.glass)
    }
    .groupBoxStyle(.card)
}
