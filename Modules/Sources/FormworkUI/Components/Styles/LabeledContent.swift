//
//  LabeledContent.swift
//  FormworkUI
//
//  Created by Daniel Wolbach on 30.09.26.
//

import SwiftUI

public struct RowLabeledContentStyle: LabeledContentStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Group(subviews: configuration.label) { subviews in
                    subviews.first

                    ForEach(subviews.dropFirst()) { subview in
                        subview
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer(minLength: 0)

            configuration.content
        }
    }
}

extension LabeledContentStyle where Self == RowLabeledContentStyle {
    public static var row: RowLabeledContentStyle {
        RowLabeledContentStyle()
    }
}

#Preview("Picker") {
    @Previewable @State
    var selection = "Metric"

    GroupBox {
        LabeledContent("Weight") {
            Picker("Weight", selection: $selection) {
                Text("Metric")
                    .tag("Metric")

                Text("Imperial")
                    .tag("Imperial")
            }
        }
    }
    .groupBoxStyle(.card)
    .labeledContentStyle(.row)
    .padding()
}

#Preview("Value") {
    GroupBox {
        VStack(spacing: 16) {
            LabeledContent {
                Text(verbatim: "12")
                    .font(.system(.title, design: .rounded, weight: .semibold))
            } label: {
                Text("Title")
                    .font(.headline)

                Text("Footnote")
            }

            Divider()

            LabeledContent {
                Text(verbatim: "—")
                    .font(.system(.title, design: .rounded, weight: .semibold))
            } label: {
                Text("Without footnote")
                    .font(.headline)
            }
        }
    }
    .groupBoxStyle(.card)
    .labeledContentStyle(.row)
    .padding()
}

#Preview("Controls") {
    @Previewable @State
    var interval = 2

    GroupBox {
        LabeledContent {
            Button("Decrease", systemImage: "minus") {
                interval -= 1
            }
            .buttonStyle(.card)
            .labelStyle(.fixedIconOnly)

            Button("Increase", systemImage: "plus") {
                interval += 1
            }
            .buttonStyle(.card)
            .labelStyle(.fixedIconOnly)
        } label: {
            Text("Every \(interval) weeks")

            Text("Counted from the start date")
        }
    }
    .groupBoxStyle(.card)
    .labeledContentStyle(.row)
    .padding()
}
