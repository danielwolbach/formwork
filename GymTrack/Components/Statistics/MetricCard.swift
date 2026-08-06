//
//  MetricCard.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 06.08.26.
//

import SwiftUI

struct MetricTrend {
    enum Direction {
        case up
        case down
    }

    let value: String
    let direction: Direction
}

struct MetricCard: View {
    let value: String
    let title: LocalizedStringResource
    let icon: String
    let tint: Color
    let trend: MetricTrend?

    init(
        value: String,
        title: LocalizedStringResource,
        icon: String,
        tint: Color = .accentColor,
        trend: MetricTrend? = nil
    ) {
        self.value = value
        self.title = title
        self.icon = icon
        self.tint = tint
        self.trend = trend
    }

    var body: some View {
        StatisticsCard(title: title, icon: icon, tint: tint) {
            Spacer()

            VStack(alignment: .leading, spacing: 2) {
                if let trend {
                    Label(trend.value, systemImage: trend.direction == .up ? "arrow.up.right" : "arrow.down.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(trend.direction == .up ? .green : .red)
                }

                Text(value)
                    .font(.system(.title, design: .rounded).weight(.bold))
                    .contentTransition(.numericText())
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .allowsTightening(true)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    MetricCard(value: "3", title: .statsThisWeek, icon: "dumbbell", tint: .green)
        .padding()
}
