//
//  StatisticsRowStack.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 06.08.26.
//

import SwiftUI

struct StatisticsRowStack<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        HStack(spacing: LayoutMetrics.compactSpacing) {
            content
        }
    }
}

#Preview {
    StatisticsRowStack {
        MetricCard(value: "3", title: .statsThisWeek, icon: "dumbbell", tint: .green)
        MetricCard(value: "12", title: .statsSessions, icon: "calendar", tint: .blue)
    }
    .padding()
}
