//
//  SelectableTile.swift
//  Formwork
//
//  Created by Daniel Wolbach on 09.09.26.
//

import FormworkKit
import SwiftUI

struct SelectableTile<Outline: InsettableShape, Content: View>: View {
    let outline: Outline
    let tint: Color
    let isSelected: Bool
    var borderWidth: CGFloat = 1.5
    let action: () -> Void

    @ViewBuilder let content: () -> Content

    private var resolvedTint: Color {
        isSelected ? tint : .secondary
    }

    var body: some View {
        Button(action: action) {
            content()
                .foregroundStyle(resolvedTint)
                .background {
                    ZStack {
                        outline.fill(.ultraThinMaterial)

                        outline.fill(resolvedTint.quinary)
                            .opacity(isSelected ? 1 : 0)
                    }
                }
                .contentShape(outline)
                .overlay {
                    outline.strokeBorder(resolvedTint.secondary, lineWidth: isSelected ? borderWidth : 0)
                }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

#Preview {
    @Previewable @State var selection: ExerciseCategory? = .arms

    VStack(spacing: 16) {
        HStack {
            ForEach(ExerciseCategory.allCases.prefix(4)) { category in
                SelectableTile(
                    outline: Capsule(),
                    tint: category.pictogram.color,
                    isSelected: selection == category
                ) {
                    selection = category
                } content: {
                    Text(category.title)
                        .font(.subheadline)
                        .lineLimit(1)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                }
            }
        }

        SelectableTile(
            outline: RoundedRectangle(cornerRadius: 12, style: .continuous),
            tint: .indigo,
            isSelected: selection == nil,
            borderWidth: 2
        ) {
            selection = nil
        } content: {
            Text(.commonPlaceholderTitle)
                .padding()
                .frame(maxWidth: .infinity)
        }
    }
    .padding()
}
