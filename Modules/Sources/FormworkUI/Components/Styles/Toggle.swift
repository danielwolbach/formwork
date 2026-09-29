//
//  Toggle.swift
//  FormworkUI
//
//  Created by Daniel Wolbach on 18.09.26.
//

import SwiftUI

public struct CardToggleStyle: ToggleStyle {
    private var tint: Color = .accentColor

    public init(tint: Color) {
        self.tint = tint
    }

    public func makeBody(configuration: Configuration) -> some View {
        let tint = configuration.isOn ? tint : .secondary

        Button {
            var transaction = Transaction(animation: nil)
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                configuration.isOn.toggle()
            }
        } label: {
            configuration.label
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .foregroundStyle(tint)
                .background {
                    ButtonBorderShape.buttonBorder.fill(Color(.quaternarySystemFill))
                    ButtonBorderShape.buttonBorder.fill(tint.quinary).opacity(configuration.isOn ? 1 : 0)
                }
                .overlay {
                    ButtonBorderShape.buttonBorder.strokeBorder(tint.secondary, lineWidth: 2)
                        .opacity(configuration.isOn ? 1 : 0)
                }
                .contentShape(ButtonBorderShape.buttonBorder)
        }
        .buttonStyle(.noFeedback)
    }
}

extension ToggleStyle where Self == CardToggleStyle {
    public static func card(tint: Color = .accentColor) -> CardToggleStyle {
        CardToggleStyle(tint: tint)
    }
}

public struct GlassToggleStyle: ToggleStyle {
    private var tint: Color = .accentColor

    public init(tint: Color) {
        self.tint = tint
    }

    public func makeBody(configuration: Configuration) -> some View {
        let glass: Glass = configuration.isOn ? .regular.tint(tint).interactive() : .regular.interactive()

        Button {
            configuration.isOn.toggle()
        } label: {
            configuration.label
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .foregroundStyle(configuration.isOn ? .white : .secondary)
                .animation(.easeOut(duration: 0.1), value: configuration.isOn)
        }
        .buttonStyle(.plain)
        .glassEffect(glass, in: .capsule)
    }
}

extension ToggleStyle where Self == GlassToggleStyle {
    public static func glass(tint: Color = .accentColor) -> GlassToggleStyle {
        GlassToggleStyle(tint: tint)
    }
}
