//
//  NumberStepper.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import FormworkKit
import SwiftUI

struct NumberStepper: View {
    @State private var showKeypad = false
    @Binding var value: Double

    let title: String
    let suffix: String?
    let stepSize: Double?
    let fractionLength: Int
    let range: ClosedRange<Double>

    init(
        value: Binding<Double>,
        title: String,
        suffix: String? = nil,
        stepSize: Double? = nil,
        fractionLength: Int = 1,
        range: ClosedRange<Double> = 0.0 ... 1000.0
    ) {
        self._value = value
        self.title = title
        self.suffix = suffix
        self.fractionLength = fractionLength
        self.stepSize = stepSize
        self.range = range
    }

    init(
        value: Binding<Int>,
        title: String,
        suffix: String? = nil,
        stepSize: Int? = nil,
        range: ClosedRange<Int> = 0 ... 1000
    ) {
        self.init(
            value: Binding(get: { Double(value.wrappedValue) }, set: { value.wrappedValue = Int($0.rounded()) }),
            title: title,
            suffix: suffix,
            stepSize: stepSize.map(Double.init),
            fractionLength: 0,
            range: Double(range.lowerBound) ... Double(range.upperBound)
        )
    }

    var body: some View {
        VStack(spacing: 4) {
            titleLabel

            HStack(spacing: 16) {
                if let stepSize {
                    stepButton(.decrease, by: -stepSize)
                }

                valueButton

                if let stepSize {
                    stepButton(.increase, by: stepSize)
                }
            }
        }
        .sheet(isPresented: $showKeypad) {
            NumberEntrySheet(
                value: $value,
                title: title,
                suffix: suffix,
                fractionLength: fractionLength,
                range: range
            )
        }
        .sensoryFeedback(trigger: value) { oldValue, newValue in
            newValue > oldValue ? .increase : .decrease
        }
    }

    private var titleLabel: some View {
        Text(title)
            .font(.subheadline)
            .lineLimit(1)
            .foregroundStyle(.secondary)
    }

    private func stepButton(_ descriptor: ActionDescriptor, by delta: Double) -> some View {
        Button(descriptor) {
            withAnimation {
                value = clamped(value + delta)
            }
        }
        .labelStyle(.fixedIconOnly)
        .buttonStyle(.glass)
        .buttonBorderShape(.circle)
    }

    private var valueButton: some View {
        Button {
            showKeypad = true
        } label: {
            ValueLabel(text: text, suffix: suffix, value: value)
        }
        .buttonStyle(.plain)
    }

    private var text: String {
        value.formatted(.number.precision(.fractionLength(fractionLength)))
    }

    private func clamped(_ raw: Double) -> Double {
        min(max(raw, range.lowerBound), range.upperBound)
    }
}

private struct NumberEntrySheet: View {
    @Environment(\.dismiss) private var dismiss: DismissAction
    @State private var draft = ""
    @Binding var value: Double

    let title: String
    let suffix: String?
    let fractionLength: Int
    let range: ClosedRange<Double>

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                ValueLabel(
                    text: draft.isEmpty ? text : draft,
                    suffix: suffix,
                    value: value,
                    isPlaceholder: draft.isEmpty
                )

                DecimalKeypad(text: $draft, fractionLength: fractionLength, upperBound: range.upperBound)
                    .padding(.horizontal)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(.confirm) {
                        confirm()
                    }
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button(.cancel) {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }

    private var text: String {
        value.formatted(.number.precision(.fractionLength(fractionLength)))
    }

    private func confirm() {
        let parsed = Double(draft.replacingOccurrences(of: Locale.currentDecimalSeparator, with: "."))

        guard let parsed else {
            return
        }

        value = min(max(parsed, range.lowerBound), range.upperBound)
        dismiss()
    }
}

private struct ValueLabel: View {
    let text: String
    let suffix: String?
    let value: Double
    var isPlaceholder: Bool = false

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text(text)
                .font(.title)
                .fontWeight(.semibold)
                .foregroundStyle(isPlaceholder ? .secondary : .primary)
                .contentTransition(.numericText(value: value))
                .monospacedDigit()

            if let suffix {
                Text(suffix)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }
        }
        .lineLimit(1)
        .frame(minWidth: 96)
        .contentShape(.rect)
    }
}

#Preview("Decimal") {
    @Previewable @State var value: Double = 0
    NumberStepper(value: $value, title: "Weight", suffix: "kg", stepSize: 5)
}

#Preview("Integer") {
    @Previewable @State var value = 0
    NumberStepper(value: $value, title: "Reps")
}
