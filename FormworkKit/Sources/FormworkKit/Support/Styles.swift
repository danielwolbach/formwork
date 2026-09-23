//
//  Styles.swift
//  Formwork
//
//  Created by Daniel Wolbach on 18.09.26.
//

import SwiftUI

public struct FixedLabelStyle: LabelStyle {
    var showsTitle: Bool = true

    @ScaledMetric
    private var iconSize: CGFloat = 20

    public func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 6) {
            icon(configuration)

            if showsTitle {
                configuration.title
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel { _ in configuration.title }
    }

    private func icon(_ configuration: Configuration) -> some View {
        configuration.icon.frame(width: iconSize, height: iconSize)
    }
}

extension LabelStyle where Self == FixedLabelStyle {
    public static var fixedIconOnly: FixedLabelStyle {
        FixedLabelStyle(showsTitle: false)
    }

    public static var fixedTitleAndIcon: FixedLabelStyle {
        FixedLabelStyle(showsTitle: true)
    }
}

public struct ChipLabelStyle: LabelStyle {
    var tint: Color = .accentColor

    @ScaledMetric
    private var iconSize: CGFloat = 20

    public func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 6) {
            icon(configuration)
            configuration.title
        }
        .font(.subheadline)
        .lineLimit(1)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .foregroundStyle(tint)
        .background {
            Capsule().fill(tint.quinary)
        }
        .contentShape(Capsule())
    }

    private func icon(_ configuration: Configuration) -> some View {
        configuration.icon.frame(width: iconSize, height: iconSize)
    }
}

extension LabelStyle where Self == ChipLabelStyle {
    public static func chip(tint: Color = .accentColor) -> ChipLabelStyle {
        ChipLabelStyle(tint: tint)
    }
}

public struct CardToggleStyle: ToggleStyle {
    var tint: Color = .accentColor

    public func makeBody(configuration: Configuration) -> some View {
        let tint = configuration.isOn ? tint : .secondary

        Button {
            configuration.isOn.toggle()
        } label: {
            configuration.label
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .foregroundStyle(tint)
                .background {
                    ButtonBorderShape.buttonBorder.fill(.ultraThinMaterial)
                    ButtonBorderShape.buttonBorder.fill(tint.quinary).opacity(configuration.isOn ? 1 : 0)
                }
                .overlay {
                    ButtonBorderShape.buttonBorder.strokeBorder(tint.secondary, lineWidth: 2).opacity(configuration.isOn ? 1 : 0)
                }
                .contentShape(ButtonBorderShape.buttonBorder)
        }
        .buttonStyle(.plain)
    }
}

extension ToggleStyle where Self == CardToggleStyle {
    public static func card(tint: Color = .accentColor) -> CardToggleStyle {
        CardToggleStyle(tint: tint)
    }
}

public struct GlassToggleStyle: ToggleStyle {
    var tint: Color = .accentColor

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

#Preview("Fixed Label") {
    Label(ExerciseCategory.cardio.title, systemImage: ExerciseCategory.cardio.pictogram.image)
        .labelStyle(.fixedTitleAndIcon)
}

#Preview("Chip Label") {
    Label("Running", systemImage: "figure.run")
        .labelStyle(.chip())
}

#Preview("Card Toggle") {
    @Previewable
    @State
    var selected = false

    Toggle("Running", systemImage: "figure.run", isOn: $selected)
        .toggleStyle(.card())
}

#Preview("Glass Toggle") {
    @Previewable
    @State
    var selected = false

    Toggle("Running", systemImage: "figure.run", isOn: $selected)
        .toggleStyle(.glass())
}
