//
//  SelectableRow.swift
//  FormworkUI
//
//  Created by Daniel Wolbach on 06.10.26.
//

import SwiftUI

public struct SelectableRow<Content: View>: View {
    private let isSelected: Bool

    private let action: () -> Void

    private let content: Content

    public init(isSelected: Bool, action: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.isSelected = isSelected
        self.action = action
        self.content = content()
    }

    public var body: some View {
        Button(action: action) {
            HStack {
                content

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isSelected ? AnyShapeStyle(.tint) : AnyShapeStyle(.tertiary))
                    .animation(.snappy(duration: 0.1), value: isSelected)
                    .accessibilityHidden(true)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}
