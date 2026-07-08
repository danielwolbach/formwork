//
//  ScreenStack\.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import SwiftUI

struct ScreenStack<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 32) {
            content
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    ScreenStack() {
        Text("Hello")
        Text("World")
    }
}
