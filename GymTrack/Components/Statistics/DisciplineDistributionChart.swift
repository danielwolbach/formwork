import Charts
import SwiftUI

struct DisciplineDistributionChart: View {
    let data: [Discipline: Double]

    private let columns = [
        GridItem(.flexible(), spacing: 8, alignment: .leading),
        GridItem(.flexible(), spacing: 8, alignment: .leading),
    ]

    var body: some View {
        StatisticsCard(title: .statsDisciplineDistribution, icon: "chart.pie", tint: .accentColor) {
            HStack(spacing: 16) {
                Chart(items, id: \.key) { item in
                    SectorMark(
                        angle: .value(String(localized: .statsExercises), item.value),
                        innerRadius: .ratio(0.6),
                        angularInset: 4
                    )
                    .foregroundStyle(item.key.color)
                }
                .frame(width: 128, height: 128)

                LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
                    ForEach(items, id: \.key) { item in
                        Label(item.key.title, systemImage: item.key.icon)
                            .font(.caption)
                            .foregroundStyle(item.key.color)
                            .labelStyle(.fixedTitleAndIcon)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
    }

    private var items: [(key: Discipline, value: Double)] {
        data.sorted { $0.value > $1.value }
    }
}

#Preview {
    DisciplineDistributionChart(data: [.legs: 3, .back: 2, .arms: 1.5, .cardio: 1])
        .padding()
}
