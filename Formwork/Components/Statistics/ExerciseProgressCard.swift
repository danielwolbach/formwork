//
//  ExerciseProgressCard.swift
//  Formwork
//
//  Created by Daniel Wolbach on 10.09.26.
//

import Charts
import FormworkKit
import SwiftUI

struct ExerciseProgressCard: View {
    let title: LocalizedStringResource
    let progress: [(date: Date, value: Double)]
    var tint: Color = .accentColor

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .lineLimit(1)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if progress.count < 2 {
                Text(verbatim: "—")
                    .font(.title)
            } else {
                chart
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial)
        .cardSurface()
    }

    private var chart: some View {
        Chart {
            ForEach(progress.indices, id: \.self) { index in
                AreaMark(
                    x: .value("", progress[index].date),
                    y: .value("", progress[index].value)
                )
                .foregroundStyle(.linearGradient(
                    colors: [tint.opacity(0.25), tint.opacity(0)],
                    startPoint: .top,
                    endPoint: .bottom
                ))

                LineMark(
                    x: .value("", progress[index].date),
                    y: .value("", progress[index].value)
                )
                .foregroundStyle(tint)
                .lineStyle(.init(lineWidth: 2, lineCap: .round, lineJoin: .round))

                PointMark(
                    x: .value("", progress[index].date),
                    y: .value("", progress[index].value)
                )
                .foregroundStyle(tint)
                .symbolSize(16)
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 3)) {
                AxisValueLabel(format: .dateTime.day().month(.abbreviated))
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: .automatic(desiredCount: 3))
        }
        .frame(height: 140)
    }
}

private struct ExerciseProgressCardGallery: View {
    private static func points(_ values: [Double]) -> [(date: Date, value: Double)] {
        let calendar = Calendar.autoupdatingCurrent

        return values.enumerated().compactMap { offset, value in
            calendar.date(byAdding: .day, value: -3 * (values.count - offset), to: .now)
                .map { (date: $0, value: value) }
        }
    }

    var body: some View {
        ScreenStack {
            ExerciseProgressCard(
                title: .statisticProgressTitle,
                progress: Self.points([40, 42.5, 42.5, 45, 45, 47.5, 50, 50, 52.5]),
                tint: .indigo
            )

            ExerciseProgressCard(
                title: .statisticProgressTitle,
                progress: Self.points([12, 10, 14, 15, 13, 16]),
                tint: .pink
            )

            ExerciseProgressCard(
                title: .statisticProgressTitle,
                progress: Self.points([20])
            )

            ExerciseProgressCard(
                title: .statisticProgressTitle,
                progress: []
            )
        }
    }
}

#Preview {
    ExerciseProgressCardGallery()
}
