//
//  ChartCard.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import SwiftUI

/// The material card the statistics' charts sit on, optionally under a title.
struct ChartCard<Content: View>: View {
    var title: String?

    @ViewBuilder
    let content: Content

    var body: some View {
        VStack(alignment: .leading) {
            if let title {
                Text(title)
                    .font(.subheadline)
                    .lineLimit(1)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            content
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(.rect(cornerRadius: 16, style: .continuous))
    }
}

#Preview {
    ChartCard(title: String(localized: .statisticActivityTitle)) {
        Capsule()
            .fill(.quaternary)
            .frame(height: 16)
    }
    .padding()
}
