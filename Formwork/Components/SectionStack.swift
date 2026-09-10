//
//  SectionStack.swift
//  Formwork
//
//  Created by Daniel Wolbach on 10.09.26.
//

import SwiftUI

struct SectionStack<Accessory: View, Content: View>: View {
    /// `Text` rather than a resource: a header is a catalog string in some
    /// places and a formatted value in others, and `Text(verbatim:)` at the
    /// call site keeps the latter out of the string catalog.
    var title: Text?

    var subtitle: Text?

    @ViewBuilder let accessory: () -> Accessory
    @ViewBuilder let content: () -> Content

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
        self.init(title: title, subtitle: subtitle, accessory: { EmptyView() }, content: content)
    }
}

#Preview {
    ScreenStack {
        SectionStack(
            title: Text(.overviewTodayTitle),
            subtitle: Text(verbatim: Date.now.formatted(.dateTime.weekday(.wide).day().month(.wide))),
            accessory: {
                Button(.startSession) {}
                    .labelStyle(.fixedTitleAndIcon)
                    .tint(.green)
                    .buttonStyle(.glassProminent)
            }
        ) {
            RowStack(navigating: Array(Samples.exercises.prefix(3)))
        }

        SectionStack {
            RestingView(.unscheduled)
        }
    }
    .sampleData()
}
