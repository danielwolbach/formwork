//
//  CategoriesSheet.swift
//  Formwork
//
//  Created by Daniel Wolbach on 24.09.26.
//

import Charts
import FormworkKit
import FormworkUI
import SwiftUI

struct CategoriesSheet: View {
    private let history: History

    init(history: History) {
        self.history = history
    }

    var body: some View {
        let recent = Categories(history.recent)

        StatisticSheet(recent, history: history) {
            SectionView(.init(localized: .fieldRecentTitle), subtitle: .init(localized: .fieldRecentSubtitle(days: History.recentDays))) {
                CategoriesBreakdown(recent)
                    .padding()
                    .card()
                    .padding(.horizontal)
            }

            SectionView(.init(localized: .fieldOverallTitle)) {
                CategoriesBreakdown(Categories(history.allTime))
                    .padding()
                    .card()
                    .padding(.horizontal)
            }

            YearSection(years: history.years) { year in
                CategoriesChart(series: Series<Categories>(history, year: year))
            }
        }
        .tint(recent.pictogram.color)
    }
}

struct CategoriesChart: View {
    let series: Series<Categories>

    var body: some View {
        Chart(series.bars) { bar in
            ForEach(bar.statistic.shares) { share in
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
    NavigationStack {}
        .sheet(isPresented: .constant(true)) {
            CategoriesSheet(history: History(.all(Samples.sessions)))
        }
}
