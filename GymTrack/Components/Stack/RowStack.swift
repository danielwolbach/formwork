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
    }
}

#Preview {
    RowStack {
        Text("First row")
        Divider()
        Text("Second row")
    }
    .padding()
}
