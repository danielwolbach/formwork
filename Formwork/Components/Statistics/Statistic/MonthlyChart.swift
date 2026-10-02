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
    private let monthly: StatisticDetails.MonthlyBars

    init(_ monthly: StatisticDetails.MonthlyBars) {
        self.monthly = monthly
    }

    var body: some View {
        Chart(monthly.bars) { bar in
            if let value = bar.value {
                BarMark(
                    x: .value(.placeholder, bar.month, unit: .month),
                    y: .value(.placeholder, value)
                )
                .foregroundStyle(.tint)
            }
        }
        .chartXScale(domain: monthly.period.start ... monthly.period.end)
        .chartXAxis {
            AxisMarks(values: .stride(by: .month)) {
                AxisValueLabel(format: .dateTime.month(.narrow), centered: true)
            }
        }
        .readingAxis(upTo: monthly.bars.compactMap(\.value).max() ?? 0, reading: monthly.reading)
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
