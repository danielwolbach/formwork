//
//  HeatmapCard.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 22.09.26.
//

import SwiftUI

public struct HeatmapCard: View {
    private let heatmap: Heatmap

    public init(_ heatmap: Heatmap) {
        self.heatmap = heatmap
    }

    public var body: some View {
        let weeks = heatmap.weeks(15)

        VStack {
            Text(heatmap.title)
                .font(.subheadline)
                .lineLimit(1)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer(minLength: 0)

            if weeks.isEmpty {
                Image(systemName: heatmap.pictogram.image)
                    .foregroundStyle(.tertiary)

                Spacer(minLength: 0)
            } else {
                HStack(spacing: 2) {
                    weekdays

                    ForEach(weeks) { week in
                        column(of: week)
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(.rect(cornerRadius: 16, style: .continuous))
    }

    private var weekdays: some View {
        VStack(spacing: 2) {
            ForEach(heatmap.weekdays) { weekday in
                cell(.clear)
                    .overlay {
                        Text(verbatim: weekday.symbol())
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    }
            }
        }
        .font(.caption2)
        .foregroundStyle(.tertiary)
    }

    private func cell(_ style: some ShapeStyle) -> some View {
        RoundedRectangle(cornerRadius: 4, style: .continuous)
            .fill(style)
            .aspectRatio(1, contentMode: .fit)
    }

    private func column(of week: Heatmap.Week) -> some View {
        VStack(spacing: 2) {
            ForEach(week.days) { day in
                cell(fill(of: day))
            }
        }
    }

    private func fill(of day: Heatmap.Day) -> AnyShapeStyle {
        if day.isAhead {
            AnyShapeStyle(.clear)
        } else if day.value == nil {
            AnyShapeStyle(.gray.quaternary)
        } else {
            AnyShapeStyle(heatmap.pictogram.color)
        }
    }
}

private struct HeatmapPreview: View {
    let workout: Workout

    var body: some View {
        TileGrid {
            HeatmapCard(workout.statistics().activity)
                .tileSpan(rows: 2, columns: 2)
        }
    }
}

#Preview {
    HeatmapPreview(workout: Samples.workouts[0])
        .padding()
        .sampleData()
}
