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
    private let history: History

    private let year: Int

    init(_ history: History, year: Int) {
        self.history = history
        self.year = year
    }

    var body: some View {
        let span = history.year(year).span

        Chart(history.months(in: year).filter(\.isOnRecord), id: \.span.start) { month in
            ForEach(Categories(month).shares) { share in
                BarMark(
                    x: .value(.chartMonth, month.span.start, unit: .month),
                    y: .value(share.category.title, share.count)
                )
                .foregroundStyle(share.category.pictogram.color)
            }
        }
        .chartXScale(domain: span.start ... span.end)
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

    CategoriesChart(history, year: history.years.upperBound)
        .padding()
}
