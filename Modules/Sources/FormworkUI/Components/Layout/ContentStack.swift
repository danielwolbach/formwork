//
//  ContentStack.swift
//  FormworkUI
//
//  Created by Daniel Wolbach on 30.09.26.
//

import SwiftUI

public struct ContentStack<Content: View>: View {
    private let spacing: CGFloat

    private let content: Content

    public init(spacing: CGFloat = .sections, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }

    public var body: some View {
        VStack(spacing: spacing) {
            ForEach(subviews: content) { subview in
                subview.padding(.horizontal, subview.containerValues.isEdgeToEdge ? 0 : nil)
            }
        }
    }
}

extension ContainerValues {
    @Entry
    var isEdgeToEdge = false
}

extension View {
    public func edgeToEdge() -> some View {
        containerValue(\.isEdgeToEdge, true)
    }
}

#Preview {
    ScrollView {
        ContentStack {
            TileGrid {
                ForEach(1 ... 4, id: \.self) { index in
                    GroupBox {
                        Text(verbatim: "\(index)")
                            .font(.title)

                        Spacer(minLength: 0)
                    } label: {
                        Text("Tile")
                    }
                }
            }

            GroupBox {
                VStack(spacing: .groups) {
                    LabeledContent("First", value: "1")

                    Divider()

                    LabeledContent("Second", value: "2")
                }
            }
            .labeledContentStyle(.row)

            LazyVStack(spacing: 0) {
                ForEach(1 ... 3, id: \.self) { index in
                    HStack {
                        Text("Edge-to-Edge Row \(index)")

                        Spacer(minLength: 0)

                        Image(systemName: "chevron.forward")
                            .foregroundStyle(.tertiary)
                    }
                    .padding(8)
                    .background(.ultraThinMaterial)
                }
            }
            .edgeToEdge()
        }
    }
    .groupBoxStyle(.card)
}
