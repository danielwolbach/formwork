//
//  NumberStepper.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import SwiftUI

struct NumberStepper: View {
    @State private var showingKeypad = false
    @State private var draft = ""

    @Binding private var value: Double

    let title: LocalizedStringKey
    let step: Double?
    let range: ClosedRange<Double>
    let suffix: String?
    let style: Style

    init(
        value: Binding<Int>,
        title: LocalizedStringKey,
        step: Int? = nil,
        range: ClosedRange<Int> = 0 ... 1_000_000,
        suffix: String? = nil
    ) {
        _value = Binding(
            get: { Double(value.wrappedValue) },
            set: { value.wrappedValue = Int($0.rounded()) }
        )

        self.title = title
        self.step = step.map(Double.init)
        self.range = Double(range.lowerBound) ... Double(range.upperBound)
        self.suffix = suffix
        style = .integer
    }

    init(
        value: Binding<Double>,
        title: LocalizedStringKey,
        step: Double? = nil,
        range: ClosedRange<Double> = 0 ... 1_000_000,
        suffix: String? = nil,
        fractionDigits: Int = 1
    ) {
        _value = value
        self.title = title
        self.step = step
        self.range = range
        self.suffix = suffix
        style = .decimal(fractionDigits: fractionDigits)
    }

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                if let step {
                    stepButton(.decrease, disabled: value <= range.lowerBound) {
                        adjust(by: -step)
                    }
                }

                Button {
                    showingKeypad = true
                } label: {
                    valueLabel
                }
                .buttonStyle(.plain)

                if let step {
                    stepButton(.increase, disabled: value >= range.upperBound) {
                        adjust(by: step)
                    }
                }
            }
        }
        .sheet(isPresented: $showingKeypad) {
            NumberInputSheet(
                draft: $draft,
                title: title,
                formattedValue: formattedValue,
                suffix: suffix,
                allowsDecimal: !style.isInteger,
                isValid: valid,
                confirm: confirm,
                cancel: { showingKeypad = false }
            )
            .onAppear {
                draft = ""
            }
        }
    }

    private var decimalSeparator: String {
        Locale.current.decimalSeparator ?? "."
    }

    private var parsedDraft: Double? {
        Double(draft.replacingOccurrences(of: decimalSeparator, with: "."))
    }

    private var valid: Bool {
        draft.isEmpty || parsedDraft != nil
    }

    private var formattedValue: String {
        switch style {
        case .integer:
            String(Int(value.rounded()))
        case let .decimal(fractionDigits):
            value.formatted(.number.precision(.fractionLength(fractionDigits)))
        }
    }

    private var valueLabel: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text(formattedValue)
                .font(.title)
                .fontWeight(.bold)

            if let suffix {
                Text(suffix)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(minWidth: 72)
        .contentShape(.rect)
    }

    private func adjust(by amount: Double) {
        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
            let adjusted = value + amount
            value = min(max(adjusted, range.lowerBound), range.upperBound)
        }
    }

    private func confirm() {
        if let parsedDraft {
            let adjusted = min(max(parsedDraft, range.lowerBound), range.upperBound)
            value = style.isInteger ? adjusted.rounded() : adjusted
        }

        showingKeypad = false
    }

    private func stepButton(_ descriptor: ActionDescriptor, disabled: Bool, action: @escaping () -> Void) -> some View {
        IconButton(descriptor) {
            action()
        }
        .disabled(disabled)
    }
}

private struct NumberInputSheet: View {
    @Binding var draft: String

    let title: LocalizedStringKey
    let formattedValue: String
    let suffix: String?
    let allowsDecimal: Bool
    let isValid: Bool
    let confirm: () -> Void
    let cancel: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(draft.isEmpty ? formattedValue : draft)
                        .font(.system(size: 48, weight: .semibold))
                        .foregroundStyle(draft.isEmpty ? .tertiary : .primary)

                    if let suffix {
                        Text(suffix)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                    }
                }

                DecimalKeypad(text: $draft, allowsDecimal: allowsDecimal)
                    .padding(.horizontal)

                Spacer()
            }
            .padding(.top, 24)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(.confirm, action: confirm)
                        .disabled(!isValid)
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button(.cancel, action: cancel)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

extension NumberStepper {
    enum Style {
        case integer
        case decimal(fractionDigits: Int)

        var isInteger: Bool {
            if case .integer = self {
                true
            } else {
                false
            }
        }
    }
}

#Preview {
    @Previewable @State var weight = 40.0

    NumberStepper(value: $weight, title: "Weight", step: 5, suffix: "kg")
        .padding()
}
