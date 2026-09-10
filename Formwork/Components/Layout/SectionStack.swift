//
//  SectionStack.swift
//  Formwork
//
//  Created by Daniel Wolbach on 10.09.26.
//

import SwiftUI

struct SectionStack<Content: View, Accessory: View>: View {
    var title: Text?
    var subtitle: Text?

    @ViewBuilder let content: () -> Content
    @ViewBuilder let accessory: () -> Accessory

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if title != nil || subtitle != nil {
                HStack {
                    VStack(alignment: .leading) {
                        if let title {
                            title
                                .font(.headline)
                        }

                        if let subtitle {
                            subtitle
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()

                    accessory()
                }
                .padding(.horizontal, 4)
            }

            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension SectionStack where Accessory == EmptyView {
    init(
        title: Text? = nil,
        subtitle: Text? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(title: title, subtitle: subtitle, content: content, accessory: { EmptyView() })
    }
}

#Preview {
    ScreenStack {
        SectionStack(
            title: Text(.overviewTodayTitle),
            subtitle: Text(verbatim: Date.now.formatted(.dateTime.weekday(.wide).day().month(.wide)))
        ) {
            RowStack(navigating: Array(Samples.exercises.prefix(3)))
        } accessory: {
            Button(.startSession) {}
                .labelStyle(.fixedTitleAndIcon)
                .tint(.green)
                .buttonStyle(.glassProminent)
        }

        SectionStack {
            RestingView(kind: .unscheduled)
        }
    }
    .sampleData()
}
