//
//  DecimalKeypad.swift
//  FormworkUI
//
//  Created by Daniel Wolbach on 09.09.26.
//

import FormworkKit
import SwiftUI

struct DecimalKeypad: View {
    let fractionLength: Int

    let upperBound: Double

    @Binding
    var text: String

    var body: some View {
        TileGrid(columns: 3) {
            ForEach(1 ... 9, id: \.self) { digit in
                key(action: { appendDigit(String(digit)) }) {
                    digitLabel(String(digit))
                }
            }

            if fractionLength > 0 {
                key(action: appendSeparator) {
                    digitLabel(Locale.currentDecimalSeparator)
                }
                .accessibilityLabel(Text(.keypadDecimalSeparatorLabel))
            } else {
                Color.clear.frame(height: 48)
            }

            key(action: { appendDigit("0") }) {
                digitLabel("0")
            }

            key(action: deleteLast) {
                Image(systemName: "delete.backward")
                    .font(.title3)
            }
            .accessibilityLabel(Text(Action.delete.title))
        }
    }

    private func digitLabel(_ label: String) -> some View {
        Text(label)
            .font(.title2)
            .fontWeight(.medium)
    }

    private func key(action: @escaping () -> Void, @ViewBuilder label: () -> some View) -> some View {
        Button(action: action) {
            label()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(.rect)
        }
        .buttonStyle(.glass)
    }

    private func appendDigit(_ digit: String) {
        let candidate = text == "0" ? digit : text + digit

        guard withinFractionDigits(candidate), withinRange(candidate) else {
            return
        }

        text = candidate
    }

    private func deleteLast() {
        if !text.isEmpty {
            text.removeLast()
        }
    }

    private func appendSeparator() {
        guard fractionLength > 0, !text.contains(Locale.currentDecimalSeparator) else {
            return
        }

        text += text.isEmpty ? "0\(Locale.currentDecimalSeparator)" : Locale.currentDecimalSeparator
    }

    private func withinFractionDigits(_ candidate: String) -> Bool {
        guard let separatorRange = candidate.range(of: Locale.currentDecimalSeparator) else {
            return true
        }

        return candidate[separatorRange.upperBound...].count <= fractionLength
    }

    private func withinRange(_ candidate: String) -> Bool {
        guard let value = try? Double(candidate, format: .number) else {
            return true
        }

        return value <= upperBound
    }
}

#Preview("Decimal") {
    DecimalKeypad(fractionLength: 1, upperBound: 100, text: .constant(""))
        .padding()
}

#Preview("Integer") {
    DecimalKeypad(fractionLength: 0, upperBound: 100, text: .constant(""))
        .padding()
}
