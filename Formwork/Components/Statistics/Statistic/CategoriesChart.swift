//
//  CategoriesChart.swift
//  Formwork
//
//  Created by Daniel Wolbach on 24.09.26.
//

import Charts
import FormworkKit
import FormworkUI
import SwiftUI

struct CategoriesChart: View {
    let series: Series<Categories>

    var body: some View {
        Chart(series.bars) { bar in
            ForEach(bar.value.shares) { share in
                BarMark(
                    x: .value(.placeholder, bar.month, unit: .month),
                    y: .value(share.category.title, share.count)
                )
                .foregroundStyle(share.category.pictogram.color)
            }
        }
        .chartXScale(domain: series.period.start ... series.period.end)
        .chartXAxis {
            AxisMarks(values: .stride(by: .month)) {
                AxisValueLabel(format: .dateTime.month(.narrow), centered: true)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .frame(height: 200)
    }
}

#Preview {
    let history = History(.all, among: Samples.sessions)

    CategoriesChart(series: Series(history, year: history.years.upperBound, value: Categories.init))
        .padding()
}
