//
//  Button.swift
//  FormworkUI
//
//  Created by Daniel Wolbach on 26.09.26.
//

import SwiftUI

public struct NoFeedbackButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

extension ButtonStyle where Self == NoFeedbackButtonStyle {
    public static var noFeedback: NoFeedbackButtonStyle {
        NoFeedbackButtonStyle()
    }
}

public struct CardButtonStyle: ButtonStyle {
    private var tint: Color = .accentColor

    private var isProminent = false

    public init(tint: Color, isProminent: Bool = false) {
        self.tint = tint
        self.isProminent = isProminent
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .foregroundStyle(isProminent ? Color.white : tint)
            .background {
                ButtonBorderShape.buttonBorder.fill(isProminent ? tint : Color(.quaternarySystemFill))
            }
            .contentShape(ButtonBorderShape.buttonBorder)
            .opacity(configuration.isPressed ? 0.6 : 1)
    }
}

extension ButtonStyle where Self == CardButtonStyle {
    public static func card(tint: Color = .primary) -> CardButtonStyle {
        CardButtonStyle(tint: tint)
    }

    public static func cardProminent(tint: Color = .accentColor) -> CardButtonStyle {
        CardButtonStyle(tint: tint, isProminent: true)
    }
}
