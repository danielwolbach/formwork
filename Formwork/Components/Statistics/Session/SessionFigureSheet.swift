//
//  SessionFigureSheet.swift
//  Formwork
//
//  Created by Daniel Wolbach on 02.10.26.
//

import Charts
import FormworkKit
import FormworkUI
import SwiftUI

struct SessionFigureSheet: View {
    private let kind: SessionFigureKind

    private let session: Session

    private let sessions: [Session]

    init(_ kind: SessionFigureKind, of session: Session, among sessions: [Session]) {
        self.kind = kind
        self.session = session
        self.sessions = sessions
    }

    var body: some View {
        let definition = kind.definition
        let comparison = SessionComparison(kind, of: session, among: sessions)
        let points = comparison.points()

        DetailSheet(definition.pictogram, title: definition.title, subtitle: session.title, info: definition.info) {
            GroupBox {
                ValueComparison(comparison)
            }
            .groupBoxStyle(.card)

            if points.count > 1 {
                SectionView(.init(localized: .placeholder)) {
                    GroupBox {
                        SessionChart(kind: kind, points: points)
                    }
                    .groupBoxStyle(.card)
                }
            }
        }
    }
}

private struct SessionChart: View {
    let kind: SessionFigureKind

    let points: [SessionComparison.Point]

    var body: some View {
        let baseline = points.filter(\.isBaseline).map(\.id)

        Chart {
            if let first = baseline.min(), let last = baseline.max() {
                RectangleMark(
                    xStart: .value(.placeholder, Double(first) - 0.5),
                    xEnd: .value(.placeholder, Double(last) + 0.5)
                )
                .foregroundStyle(.tint.opacity(0.12))
            }

            ForEach(points) { point in
                if let value = point.value {
                    LineMark(x: .value(.placeholder, Double(point.id)), y: .value(.placeholder, value))
                        .foregroundStyle(.tint)

                    PointMark(x: .value(.placeholder, Double(point.id)), y: .value(.placeholder, value))
                        .foregroundStyle(.tint)
                        .symbolSize(point.isCurrent ? 120 : 30)
                }
            }
        }
        .chartXScale(domain: -0.5 ... Double(points.count) - 0.5)
        .chartXAxis {
            AxisMarks(values: [0, Double(points.count - 1)]) { mark in
                if let index = mark.as(Double.self).map(Int.init), points.indices.contains(index) {
                    // Centered labels at the plot's edges overflow it and get dropped.
                    AxisValueLabel(anchor: index == 0 ? .topLeading : .topTrailing) {
                        Text(points[index].date, format: .dateTime.day().month(.abbreviated))
                    }
                }
            }
        }
        .readingAxis(upTo: points.compactMap(\.value).max() ?? 0, reading: kind.reading(of:))
        .frame(height: 192)
    }
}

#Preview("Measure") {
    NavigationStack {}
        .sheet(isPresented: .constant(true)) {
            NavigationStack {
                SessionFigureSheet(.volume, of: Samples.sessions.first!, among: Samples.sessions)
            }
            .presentationDetents([.medium, .large])
        }
        .sampleData()
}

#Preview("Clock") {
    NavigationStack {}
        .sheet(isPresented: .constant(true)) {
            NavigationStack {
                SessionFigureSheet(.endTime, of: Samples.sessions.first!, among: Samples.sessions)
            }
            .presentationDetents([.medium, .large])
        }
        .sampleData()
}
