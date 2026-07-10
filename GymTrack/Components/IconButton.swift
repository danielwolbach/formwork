//
//  IconButton.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 10.07.26.
//

import SwiftUI

struct IconButton<Style: PrimitiveButtonStyle>: View {
    let label: LocalizedStringKey
    let systemImage: String
    let role: ButtonRole?
    let style: Style
    let action: () -> Void

    init(_ descriptor: ActionDescriptor, style: Style = .glass, action: @escaping () -> Void) {
        label = descriptor.title
        systemImage = descriptor.systemImage
        role = descriptor.role
        self.style = style
        self.action = action
    }

    init(
        _ label: LocalizedStringKey,
        systemImage: String,
        role: ButtonRole? = nil,
        style: Style = .glass,
        action: @escaping () -> Void
    ) {
        self.label = label
        self.systemImage = systemImage
        self.role = role
        self.style = style
        self.action = action
    }

    var body: some View {
        Button(role: role, action: action) {
            Image(systemName: systemImage)
                .frame(width: 16, height: 16)
        }
        .accessibilityLabel(label)
        .buttonBorderShape(.circle)
        .buttonStyle(style)
    }
}

#Preview {
    HStack(spacing: 12) {
        IconButton(.decrease) {}

        LabelButton(.confirm, style: .glassProminent) {}
            .fontWeight(.semibold)
            .tint(.green)

        IconButton(.increase) {}
    }
    .controlSize(.large)
    .padding()
}
