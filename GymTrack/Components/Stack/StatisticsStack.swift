//
//  StatisticsStack.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 06.08.26.
//

import SwiftUI

struct StatisticsStack<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: LayoutMetrics.compactSpacing) {
            content
        }
    }
}

#Preview {
    StatisticsStack {
        Text("First card")
        Text("Second card")
    }
    .padding()
}
