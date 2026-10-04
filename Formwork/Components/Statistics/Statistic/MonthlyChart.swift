//
//  MonthlyChart.swift
//  Formwork
//
//  Created by Daniel Wolbach on 24.09.26.
//

import Charts
import FormworkKit
import FormworkUI
import SwiftUI

struct MonthlyChart: View {
    private let series: Series<Double?>

    private let reading: (Double) -> Reading

    init(_ series: Series<Double?>, reading: @escaping (Double) -> Reading) {
        self.series = series
        self.reading = reading
    }

    var body: some View {
        Chart(series.bars) { bar in
            if let value = bar.value {
                BarMark(
                    x: .value(.placeholder, bar.month, unit: .month),
                    y: .value(.placeholder, value)
                )
                .foregroundStyle(.tint)
            }
        }
        .chartXScale(domain: series.period.start ... series.period.end)
        .chartXAxis {
            AxisMarks(values: .stride(by: .month)) {
                AxisValueLabel(format: .dateTime.month(.narrow), centered: true)
            }
        }
        .readingAxis(upTo: series.bars.compactMap(\.value).max() ?? 0, reading: reading)
        .frame(height: 192)
    }
}

#Preview {
    NavigationStack {}
        .sheet(isPresented: .constant(true)) {
            NavigationStack {
                StatisticSheet(.completionRate, of: History(.all, among: Samples.sessions))
            }
            .presentationDetents([.medium, .large])
        }
        .sampleData()
}
