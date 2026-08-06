//
//  StatisticsCard.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 06.08.26.
//

import SwiftUI

struct StatisticsCard<Content: View>: View {
    let title: LocalizedStringResource
    let icon: String
    let tint: Color
    @ViewBuilder let content: Content

    init(
        title: LocalizedStringResource,
        icon: String,
        tint: Color = .accentColor,
        titleLineLimit: Int? = nil,
        minimumHeight: CGFloat? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.icon = icon
        self.tint = tint
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label(title, systemImage: icon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(tint)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .allowsTightening(true)
            
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 128, alignment: .topLeading)
        .background(.ultraThinMaterial)
        .clipShape(.rect(cornerRadius: 12, style: .continuous))
    }
}

#Preview {
    StatisticsCard(title: .screenStats, icon: "chart.bar", tint: .green) {
        Text("Hello World")
            .font(.largeTitle.bold())
    }
    .padding()
}
