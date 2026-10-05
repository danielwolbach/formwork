//
//  SectionView.swift
//  FormworkUI
//
//  Created by Daniel Wolbach on 20.09.26.
//

import SwiftUI

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

    public init(_ title: LocalizedStringResource, subtitle: String? = nil, @ViewBuilder content: () -> Content, @ViewBuilder accessory: () -> Accessory) {
        self.init(String(localized: title), subtitle: subtitle, content: content, accessory: accessory)
    }

    public var body: some View {
        ContentStack(spacing: .items) {
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
                            .contentTransition(.opacity)
                            .animation(.snappy, value: subtitle)
                    }
                }

                Spacer(minLength: 0)

                accessory
            }
            // Optical alignment with rounded cards.
            .padding(.horizontal, 2)

            content
        }
        // Applies the margins itself, so content marked edge to edge can reach the screen edges.
        .edgeToEdge()
    }
}

extension SectionView where Accessory == EmptyView {
    public init(_ title: String, subtitle: String? = nil, @ViewBuilder content: () -> Content) {
        self.init(title, subtitle: subtitle, content: content, accessory: { EmptyView() })
    }

    public init(_ title: LocalizedStringResource, subtitle: String? = nil, @ViewBuilder content: () -> Content) {
        self.init(String(localized: title), subtitle: subtitle, content: content, accessory: { EmptyView() })
    }
}

#Preview {
    SectionView("Title", subtitle: "Subtitle") {
        GroupBox {
            Text("Hello World")
        }
    } accessory: {
        Button("Accessory") {
            // Do nothing.
        }
        .buttonStyle(.glass)
    }
    .groupBoxStyle(.card)
}

#Preview("Edge to edge") {
    ScrollView {
        ContentStack {
            SectionView("Card") {
                GroupBox {
                    Text("Hello World")
                }
            }

            SectionView("List") {
                LazyVStack(spacing: 0) {
                    ForEach(1 ... 3, id: \.self) { index in
                        Text("Row \(index)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(.fill.quaternary)
                    }
                }
                .edgeToEdge()
            }
        }
    }
    .groupBoxStyle(.card)
}
