//
//  DecimalKeypad.swift
//  Formwork
//
//  Created by Daniel Wolbach on 09.09.26.
//

import SwiftUI

struct DecimalKeypad: View {
    @Binding var text: String

    let fractionLength: Int
    let upperBound: Double

    var body: some View {
        LazyVGrid(columns: GridItem.ntile(n: 3, spacing: 12), spacing: 12) {
            ForEach(1 ... 9, id: \.self) { digit in
                key(action: { appendDigit(String(digit)) }) {
                    digitLabel(String(digit))
                }
            }

            if fractionLength > 0 {
                key(action: appendSeparator) {
                    digitLabel(Locale.currentDecimalSeparator)
                }
            } else {
                Color.clear.frame(height: 48)
            }

            key(action: { appendDigit("0") }) {
                digitLabel("0")
            }

            key(action: {
                if !text.isEmpty {
                    text.removeLast()
                }
            }) {
                Image(systemName: "delete.backward")
                    .font(.title3)
            }
        }
    }

    private func appendDigit(_ digit: String) {
        let candidate = text + digit

        guard withinFractionDigits(candidate), withinRange(candidate) else {
            return
        }

        text = candidate
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
        guard let value = Double(candidate.replacingOccurrences(of: Locale.currentDecimalSeparator, with: ".")) else {
            return true
        }

        return value <= upperBound
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
                .aspectRatio(2, contentMode: .fill)
                .contentShape(.rect)
        }
        .buttonStyle(.glass)
    }
}

#Preview("Decimal") {
    DecimalKeypad(text: .constant(""), fractionLength: 1, upperBound: 100)
        .padding()
}

#Preview("Integer") {
    DecimalKeypad(text: .constant(""), fractionLength: 0, upperBound: 100)
        .padding()
}
