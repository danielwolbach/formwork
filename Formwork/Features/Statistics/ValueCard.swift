//
//  ValueCard.swift
//  Formwork
//
//  Created by Daniel Wolbach on 06.09.26.
//

import FormworkKit
import SwiftUI

struct ValueCard: View {
    let title: LocalizedStringResource

    /// `nil` renders as a placeholder — how a card draws the absence of a
    /// value, so callers never spell it themselves.
    let value: String?

    let pictogram: Pictogram

    private var shape: some InsettableShape {
        .rect(cornerRadius: 16, style: .continuous)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Spacer(minLength: 0)

            Text(title)
                .font(.subheadline)
                .lineLimit(1)
                .foregroundStyle(.secondary)

            Text(verbatim: value ?? "—")
                .font(.system(.title3, design: .rounded, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .contentTransition(.numericText())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(alignment: .topTrailing) {
            Image(systemName: pictogram.icon)
                .font(.system(size: 96))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(pictogram.color)
                .opacity(0.35)
                .offset(x: 24, y: -24)
        }
        .background(pictogram.color.quinary)
        .background(.ultraThinMaterial)
        .aspectRatio(1.8, contentMode: .fit)
        .clipShape(shape)
        .contentShape(.rect)
    }
}

private struct StatCardGallery: View {
    var body: some View {
        LazyVGrid(columns: [.init(.flexible()), .init(.flexible())]) {
            ValueCard(title: .statisticStreakTitle, value: "23 Weeks", pictogram: Pictogram(icon: "flame", tint: .orange))
            ValueCard(title: .statisticLastSessionTitle, value: "2 Days Ago", pictogram: Pictogram(icon: "calendar", tint: .indigo))
            ValueCard(title: .statisticStreakTitle, value: "0 Weeks", pictogram: Pictogram(icon: "flame", tint: .orange))
            ValueCard(title: .statisticLastSessionTitle, value: nil, pictogram: Pictogram(icon: "calendar", tint: .indigo))
            ValueCard(title: .statisticStreakTitle, value: "127 Wochen", pictogram: Pictogram(icon: "flame", tint: .orange))
            ValueCard(title: .statisticLastSessionTitle, value: "Vorgestern Abend", pictogram: Pictogram(icon: "calendar", tint: .indigo))
        }
        .padding()
    }
}

#Preview {
    StatCardGallery()
}
