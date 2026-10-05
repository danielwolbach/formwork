//
//  CardButtonStyle.swift
//  FormworkModules
//
//  Created by Daniel Wolbach on 05.10.26.
//

import SwiftUI

public struct CardButtonStyle: ButtonStyle {
    public enum Style {
        case bordered, prominent, selected
    }

    private let style: Style

    @Environment(\.controlSize)
    private var controlSize

    @Environment(\.isEnabled)
    private var isEnabled

    public init(style: Style) {
        self.style = style
    }

    private var padding: EdgeInsets {
        switch controlSize {
        case .mini: EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10)
        case .small: EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10)
        case .regular: EdgeInsets(top: 7, leading: 12, bottom: 7, trailing: 12)
        case .large: EdgeInsets(top: 15, leading: 20, bottom: 15, trailing: 20)
        case .extraLarge: EdgeInsets(top: 15, leading: 20, bottom: 15, trailing: 20)
        @unknown default: EdgeInsets(top: 7, leading: 12, bottom: 7, trailing: 12)
        }
    }

    public func makeBody(configuration: Configuration) -> some View {
        let active = style == .prominent || style == .selected

        ZStack {
            configuration.label
                .foregroundStyle(.secondary)
                .opacity(active ? 0 : 1)

            configuration.label
                .foregroundStyle(.tint)
                .opacity(active ? 1 : 0)
                .accessibilityHidden(true)
        }
        .padding(padding)
        .font(controlSize == .small || controlSize == .mini ? .subheadline : .default)
        .background {
            ButtonBorderShape.buttonBorder.fill(.ultraThinMaterial)
            ButtonBorderShape.buttonBorder.fill(.tint.quinary).opacity(active ? 1 : 0)
        }
        .overlay {
            ButtonBorderShape.buttonBorder
                .strokeBorder(.tint, lineWidth: 2)
                .opacity(style == .selected ? 1 : 0)
        }
        .opacity(isEnabled ? 1 : 0.6)
        .opacity(configuration.isPressed ? 0.9 : 1)
        .animation(.snappy(duration: 0.2), value: configuration.isPressed)
        .animation(.snappy(duration: 0.1), value: style)
        .accessibilityAddTraits(style == .selected ? [.isSelected] : [])
    }
}

extension ButtonStyle where Self == CardButtonStyle {
    public static var card: CardButtonStyle {
        CardButtonStyle(style: .bordered)
    }

    public static var cardProminent: CardButtonStyle {
        CardButtonStyle(style: .prominent)
    }

    public static var cardSelected: CardButtonStyle {
        CardButtonStyle(style: .selected)
    }
}

#Preview {
    VStack {
        Button(.startSession) {}
            .buttonStyle(.card)

        Button(.startSession) {}
            .buttonStyle(.cardProminent)

        Button(.startSession) {}
            .buttonStyle(.cardSelected)
    }
}
