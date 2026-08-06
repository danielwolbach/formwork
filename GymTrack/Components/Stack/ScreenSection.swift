//
//  ScreenSection.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 06.08.26.
//

import SwiftUI

struct ScreenSection<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: LayoutMetrics.sectionSpacing) {
            content
        }
        .padding(.horizontal, LayoutMetrics.screenHorizontal)
    }
}

#Preview {
    ScreenSection {
        Text("First section")
        Text("Second section")
    }
    .padding()
}
