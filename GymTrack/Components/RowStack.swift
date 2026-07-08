//
//  RowStack.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import SwiftUI

struct RowStack<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        LazyVStack(spacing: 0) {
            content
        }
        .padding(.horizontal, 8)
    }
}

#Preview {
    RowStack {
        ForEach(["First", "Second", "Third"], id: \.self) { title in
            NavigationRow(title: title, subtitle: "Subtitle", systemImage: "sparkles", color: .accentColor)
        }
    }
}
