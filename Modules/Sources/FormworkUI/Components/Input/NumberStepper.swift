//
//  NumberStepper.swift
//  FormworkUI
//
//  Created by Daniel Wolbach on 04.09.26.
//

import FormworkKit
import SwiftUI

public struct NumberStepper: View {
    private let title: String

    private let suffix: String?

    private let stepSize: Double?

    private let fractionLength: Int

    private let range: ClosedRange<Double>

    @Binding
    private var value: Double

    @State
    private var showKeypad = false

    public init(
        _ title: String,
        value: Binding<Double>,
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

    public init(
        _ title: String,
        value: Binding<Int>,
        suffix: String? = nil,
        stepSize: Int? = nil,
        range: ClosedRange<Int> = 0 ... 1000
    ) {
        self.init(
            title,
            value: Binding(get: { Double(value.wrappedValue) }, set: { value.wrappedValue = Int($0.rounded()) }),
            suffix: suffix,
            stepSize: stepSize.map(Double.init),
            fractionLength: 0,
            range: Double(range.lowerBound) ... Double(range.upperBound)
        )
    }

    public init(
        _ title: LocalizedStringResource,
        value: Binding<Int>,
        suffix: String? = nil,
        stepSize: Int? = nil,
        range: ClosedRange<Int> = 0 ... 1000
    ) {
        self.init(String(localized: title), value: value, suffix: suffix, stepSize: stepSize, range: range)
    }

    public var body: some View {
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
                title: title,
                suffix: suffix,
                fractionLength: fractionLength,
                range: range,
                value: $value
            )
        }
        .sensoryFeedback(trigger: value) { oldValue, newValue in
            newValue > oldValue ? .increase : .decrease
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue([text, suffix].compactMap(\.self).joined(separator: " "))
        .accessibilityAdjustableAction { direction in
            guard let stepSize else {
                return
            }

            switch direction {
            case .increment: value = clamped(value + stepSize)
            case .decrement: value = clamped(value - stepSize)
            @unknown default: break
            }
        }
        .accessibilityAction {
            showKeypad = true
        }
    }

    private var titleLabel: some View {
        Text(title)
            .font(.subheadline)
            .lineLimit(1)
            .foregroundStyle(.secondary)
    }

    private var valueButton: some View {
        Button {
            showKeypad = true
        } label: {
            ValueLabel(text: text, suffix: suffix, value: value)
        }
        .buttonStyle(.plain)
        .animation(.default, value: value)
    }

    private var text: String {
        value.formatted(.number.precision(.fractionLength(fractionLength)))
    }

    private func stepButton(_ descriptor: Action, by delta: Double) -> some View {
        Button(descriptor) {
            value = clamped(value + delta)
        }
        .labelStyle(.fixedIconOnly)
        .buttonStyle(.glass)
        .buttonBorderShape(.circle)
        .disabled(delta < 0 ? value <= range.lowerBound : value >= range.upperBound)
    }

    private func clamped(_ raw: Double) -> Double {
        min(max(raw, range.lowerBound), range.upperBound)
    }
}

private struct NumberEntrySheet: View {
    let title: String

    let suffix: String?

    let fractionLength: Int

    let range: ClosedRange<Double>

    @Binding
    var value: Double

    @Environment(\.dismiss)
    private var dismiss: DismissAction

    @State
    private var draft = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                ValueLabel(
                    text: draft.isEmpty ? text : draft,
                    suffix: suffix,
                    value: value,
                    isPlaceholder: draft.isEmpty
                )

                DecimalKeypad(fractionLength: fractionLength, upperBound: range.upperBound, text: $draft)
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
        if let parsed = try? Double(draft, format: .number) {
            value = min(max(parsed, range.lowerBound), range.upperBound)
        }

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
    @Previewable
    @State
    var value: Double = 0

    NumberStepper("Weight", value: $value, suffix: "kg", stepSize: 5)
}

#Preview("Integer") {
    @Previewable
    @State
    var value = 0

    NumberStepper("Reps", value: $value)
}
