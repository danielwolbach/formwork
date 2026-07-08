//
//  DecimalKeypad.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import SwiftUI

struct DecimalKeypad: View {
    @Binding var text: String

    let allowsDecimal: Bool

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(1 ... 9, id: \.self) { digit in
                key(String(digit)) {
                    text += String(digit)
                }
            }

            if allowsDecimal {
                key(decimalSeparator, action: appendSeparator)
            } else {
                Color.clear.frame(height: 48)
            }

            key("0") {
                text += "0"
            }

            key(systemImage: "delete.backward") {
                if !text.isEmpty {
                    text.removeLast()
                }
            }
        }
    }

    private var decimalSeparator: String {
        Locale.current.decimalSeparator ?? "."
    }

    private func appendSeparator() {
        guard !text.contains(decimalSeparator) else {
            return
        }

        text += text.isEmpty ? "0\(decimalSeparator)" : decimalSeparator
    }

    private func key(_ label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.title2)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .contentShape(.rect)
        }
        .buttonStyle(.glass)
    }

    private func key(systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.title3)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .contentShape(.rect)
        }
        .buttonStyle(.glass)
    }
}

#Preview {
    @Previewable @State var text = ""

    DecimalKeypad(text: $text, allowsDecimal: true)
        .padding()
}
