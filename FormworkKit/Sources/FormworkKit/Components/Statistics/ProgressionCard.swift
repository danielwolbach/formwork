//
//  ProgressionCard.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 22.09.26.
//

import Charts
import SwiftUI

public struct ProgressionCard<Value: Rankable>: View {
    private let progression: Progression<Value>

    public init(_ progression: Progression<Value>) {
        self.progression = progression
    }

    public var body: some View {
        VStack {
            Text(progression.title)
                .font(.subheadline)
                .lineLimit(1)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            if progression.points.isEmpty {
                Image(systemName: "chart.xyaxis.line")
                    .font(.largeTitle)
                    .foregroundStyle(.tertiary)
                    .frame(maxHeight: .infinity)
            } else {
                chart
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(.rect(cornerRadius: 16, style: .continuous))
    }

    private var chart: some View {
        Chart(progression.points) { point in
            AreaMark(x: .value(dateTitle, point.date), y: .value(progression.title, point.rank))
                .interpolationMethod(.monotone)
                .foregroundStyle(gradient)

            LineMark(x: .value(dateTitle, point.date), y: .value(progression.title, point.rank))
                .interpolationMethod(.monotone)
                .foregroundStyle(progression.pictogram.color)
                .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 3)) {
                AxisValueLabel(format: .dateTime.month(.abbreviated).day())
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: .automatic(desiredCount: 3)) { mark in
                AxisGridLine()

                if let rank = mark.as(Double.self) {
                    AxisValueLabel {
                        Text(verbatim: progression.label(for: rank))
                    }
                }
            }
        }
        .chartYScale(domain: .automatic(includesZero: false))
        .font(.caption2)
        .foregroundStyle(.tertiary)
        .padding(.top)
    }

    private var gradient: LinearGradient {
        LinearGradient(
            colors: [progression.pictogram.color.opacity(0.35), progression.pictogram.color.opacity(0)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var dateTitle: String {
        String(localized: .chartDateTitle)
    }
}

private struct ProgressionPreview: View {
    let exercise: Exercise

    var body: some View {
        TileGrid {
            ProgressionCard(exercise.statistics().progression)
                .tileSpan(rows: 2, columns: 2)
        }
    }
}

#Preview {
    ProgressionPreview(exercise: Samples.exercises[10])
        .padding()
        .sampleData()
}
