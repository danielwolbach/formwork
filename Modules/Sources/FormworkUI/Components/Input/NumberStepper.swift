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

    private let stepSize: ((Double) -> Double)?

    private let format: NumberFormat

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
        self.init(
            title,
            value: value,
            suffix: suffix,
            stepSize: stepSize.map { stepSize in { _ in stepSize } },
            format: .number(fractionLength: fractionLength),
            range: range
        )
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
        _ title: String,
        seconds: Binding<Int>,
        stepSize: ((Int) -> Int)? = nil,
        range: ClosedRange<Int>
    ) {
        self.init(
            title,
            value: Binding(get: { Double(seconds.wrappedValue) }, set: { seconds.wrappedValue = Int($0.rounded()) }),
            suffix: nil,
            stepSize: stepSize.map { stepSize in { Double(stepSize(Int($0.rounded(.down)))) } },
            format: .time,
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

    init(
        _ title: String,
        value: Binding<Double>,
        suffix: String?,
        stepSize: ((Double) -> Double)?,
        format: NumberFormat,
        range: ClosedRange<Double>
    ) {
        self._value = value
        self.title = title
        self.suffix = suffix
        self.format = format
        self.stepSize = stepSize
        self.range = range
    }

    public var body: some View {
        VStack(spacing: 4) {
            titleLabel

            HStack(spacing: 16) {
                if stepSize != nil {
                    stepButton(.decrease, increases: false)
                }

                valueButton

                if stepSize != nil {
                    stepButton(.increase, increases: true)
                }
            }
        }
        .sheet(isPresented: $showKeypad) {
            NumberEntrySheet(title, value: $value, suffix: suffix, format: format, range: range)
        }
        .sensoryFeedback(trigger: value) { oldValue, newValue in
            newValue > oldValue ? .increase : .decrease
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue([format.spokenFormat(value), suffix].compactMap(\.self).joined(separator: " "))
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: step(increases: true)
            case .decrement: step(increases: false)
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
            ValueLabel(text: format.format(value), suffix: suffix, value: value)
        }
        .buttonStyle(.plain)
        .animation(.default, value: value)
    }

    private func stepButton(_ descriptor: Action, increases: Bool) -> some View {
        Button(descriptor) {
            step(increases: increases)
        }
        .labelStyle(.fixedIconOnly)
        .buttonStyle(.glass)
        .buttonBorderShape(.circle)
        .disabled(increases ? value >= range.upperBound : value <= range.lowerBound)
    }

    private func step(increases: Bool) {
        guard let stepSize else {
            return
        }

        value = clamped(increases ? value + stepSize(value) : value - stepSize(value.nextDown))
    }

    private func clamped(_ raw: Double) -> Double {
        min(max(raw, range.lowerBound), range.upperBound)
    }
}

struct ValueLabel: View {
    let text: String

    var pendingDigits: String?

    let suffix: String?

    let value: Double

    var isPlaceholder: Bool = false

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text(text)
                    .foregroundStyle(isPlaceholder ? .secondary : .primary)

                if let pendingDigits {
                    Text(pendingDigits)
                        .foregroundStyle(.secondary)
                }
            }
            .font(.title)
            .fontWeight(.semibold)
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

#Preview("Time") {
    @Previewable
    @State
    var seconds = 45

    NumberStepper("Duration", seconds: $seconds, stepSize: { $0 < 120 ? 15 : 60 }, range: 5 ... 60 * 60)
}

#Preview("Integer") {
    @Previewable
    @State
    var value = 0

    NumberStepper("Reps", value: $value)
}
