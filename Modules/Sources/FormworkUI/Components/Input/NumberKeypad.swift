//
//  NumberKeypad.swift
//  FormworkUI
//
//  Created by Daniel Wolbach on 09.09.26.
//

import FormworkKit
import SwiftUI

struct NumberKeypad: View {
    let format: NumberFormat

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

            if let separator = format.separator {
                key(action: { appendSeparator(separator) }) {
                    digitLabel(separator)
                }
                .accessibilityLabel(Text(separatorLabel))
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

    private var separatorLabel: LocalizedStringResource {
        switch format {
        case .number: .keypadDecimalSeparatorLabel
        case .time: .keypadTimeSeparatorLabel
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

        guard format.accepts(candidate), withinRange(candidate) else {
            return
        }

        text = candidate
    }

    private func deleteLast() {
        if !text.isEmpty {
            text.removeLast()
        }
    }

    private func appendSeparator(_ separator: String) {
        guard !text.contains(separator) else {
            return
        }

        text += text.isEmpty ? "0\(separator)" : separator
    }

    private func withinRange(_ candidate: String) -> Bool {
        guard let value = format.parse(candidate) else {
            return true
        }

        return value <= upperBound
    }
}

#Preview("Decimal") {
    NumberKeypad(format: .number(fractionLength: 1), upperBound: 100, text: .constant(""))
        .padding()
}

#Preview("Integer") {
    NumberKeypad(format: .number(fractionLength: 0), upperBound: 100, text: .constant(""))
        .padding()
}

#Preview("Time") {
    NumberKeypad(format: .time, upperBound: 60 * 60, text: .constant(""))
        .padding()
}
