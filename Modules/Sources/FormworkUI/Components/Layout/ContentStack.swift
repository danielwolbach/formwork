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

    public init(spacing: CGFloat = 32, @ViewBuilder content: () -> Content) {
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

#Preview("Screen") {
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
                Text("A card keeps the margin.")
            }

            LazyVStack(spacing: 0) {
                ForEach(1 ... 3, id: \.self) { index in
                    HStack {
                        Text("Row \(index)")

                        Spacer(minLength: 0)

                        Image(systemName: "chevron.forward")
                            .foregroundStyle(.tertiary)
                    }
                    .padding(8)
                    .background(.fill.quaternary)
                }
            }
            .edgeToEdge()
        }
    }
    .groupBoxStyle(.card)
}

#Preview("Nested") {
    ScrollView {
        ContentStack {
            GroupBox {
                Text("A card keeps the margin.")
            }

            // What a section containing a list would do internally.
            ContentStack(spacing: 8) {
                Text("Section")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

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
            .edgeToEdge()
        }
    }
    .groupBoxStyle(.card)
}

#Preview("Tight spacing") {
    ScrollView {
        ContentStack(spacing: 16) {
            ForEach(1 ... 3, id: \.self) { index in
                GroupBox {
                    Text("Card \(index)")
                }
            }
        }
    }
    .groupBoxStyle(.card)
}
