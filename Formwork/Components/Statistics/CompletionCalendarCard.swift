//
//  CompletionCalendarCard.swift
//  Formwork
//
//  Created by Daniel Wolbach on 10.09.26.
//

import FormworkKit
import SwiftUI

struct CompletionCalendarCard: View {
    let title: LocalizedStringResource
    let completedDays: Set<Date>
    let tint: Color

    var weeks: Int = 16

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .lineLimit(1)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            grid
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial)
        .cardSurface()
    }

    private var columns: [[Date]] {
        let calendar = Calendar.autoupdatingCurrent

        guard weeks > 0, let latest = calendar.dateInterval(of: .weekOfYear, for: .now)?.start else {
            return []
        }

        return (0 ..< weeks).reversed().compactMap { offset in
            guard let week = calendar.date(byAdding: .weekOfYear, value: -offset, to: latest) else {
                return nil
            }

            return (0 ..< 7).compactMap { index in
                calendar.date(byAdding: .day, value: index, to: week).map { calendar.startOfDay(for: $0) }
            }
        }
    }

    private var grid: some View {
        let now = Date.now

        return HStack(spacing: 2) {
            ForEach(columns, id: \.self) { week in
                VStack(spacing: 2) {
                    ForEach(week, id: \.self) { day in
                        cell(for: day, now: now)
                    }
                }
            }
        }
    }

    private func cell(for day: Date, now: Date) -> some View {
        RoundedRectangle(cornerRadius: 4, style: .continuous)
            .fill(day > now ? .clear : (completedDays.contains(day) ? tint : .primary.opacity(0.08)))
            .aspectRatio(1, contentMode: .fit)
    }
}

private struct CompletionCalendarCardGallery: View {
    private static let completedDays = Samples.statistics.completedDays

    var body: some View {
        ScreenStack {
            CompletionCalendarCard(
                title: .statisticCompletionCalendarTitle,
                completedDays: Self.completedDays,
                tint: Pictogram.streak.color
            )

            CompletionCalendarCard(
                title: .statisticCompletionCalendarTitle,
                completedDays: [],
                tint: Pictogram.streak.color
            )

            CompletionCalendarCard(
                title: .statisticCompletionCalendarTitle,
                completedDays: Self.completedDays,
                tint: .mint,
                weeks: 26
            )
        }
    }
}

#Preview {
    CompletionCalendarCardGallery()
}
