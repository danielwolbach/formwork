//
//  ButtonStack.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 06.08.26.
//

import SwiftUI

struct ButtonStack<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        HStack {
            content
        }
        .controlSize(.large)
    }
}

#Preview {
    ButtonStack {
        Button(.decrease) {}
        Button(.confirm) {}
        Button(.increase) {}
    }
    .buttonStyle(.glass)
    .padding()
}
