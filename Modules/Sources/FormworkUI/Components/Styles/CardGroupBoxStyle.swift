//
//  CardGroupBoxStyle.swift
//  FormworkModules
//
//  Created by Daniel Wolbach on 05.10.26.
//

import SwiftUI

public struct CardGroupBoxStyle: GroupBoxStyle {
    public init() {
        // Nothing to construct.
    }

    public func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: .items) {
            configuration.label
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(1)

            configuration.content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 16, style: .continuous))
    }
}

extension GroupBoxStyle where Self == CardGroupBoxStyle {
    public static var card: CardGroupBoxStyle {
        CardGroupBoxStyle()
    }
}

#Preview("Content") {
    @Previewable @State
    var name = ""

    GroupBox {
        TextField("Name", text: $name)
    }
    .groupBoxStyle(.card)
    .padding()
}

#Preview("Label") {
    GroupBox {
        Text("Keep the elbows tucked and lower the bar to the chest.")
    } label: {
        Label("Notes", systemImage: "document")
    }
    .groupBoxStyle(.card)
    .padding()
}

#Preview("Sections") {
    @Previewable @State
    var isOn = true

    ScrollView {
        ContentStack {
            SectionView("Title", subtitle: "Subtitle") {
                GroupBox {
                    Toggle("Setting", isOn: $isOn)
                }
            }

            SectionView("Title") {
                GroupBox {
                    Text("Centered content")
                        .frame(maxWidth: .infinity)
                } label: {
                    Label("Label", systemImage: "link")
                }
            }
        }
    }
    .groupBoxStyle(.card)
}
