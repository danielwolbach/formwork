//
//  NumberStepper.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import SwiftUI

struct NumberStepper: View {
    @State private var showKeypad = false
    @State private var draft = ""
    @Binding var value: Double
    
    let title: LocalizedStringResource
    let suffix: LocalizedStringResource?
    let stepSize: Double?
    let fractionLength: Int
    let range: ClosedRange<Double>
    
    init(
        value: Binding<Double>,
        title: LocalizedStringResource,
        suffix: LocalizedStringResource? = nil,
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
        title: LocalizedStringResource,
        suffix: LocalizedStringResource? = nil,
        stepSize: Int? = nil,
        range: ClosedRange<Int> = 0 ... 1000
    ) {
        self.init(
            value: Binding(get: { Double(value.wrappedValue) }, set: { value.wrappedValue = Int($0.rounded()) }),
            title: title,
            suffix: suffix,
            stepSize: stepSize == nil ? nil : Double(stepSize!),
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
            keypadSheet
        }
    }
    
    private var titleLabel: some View {
        Text(title)
            .font(.subheadline)
            .lineLimit(1)
            .foregroundStyle(.secondary)
    }
    
    private func stepButton(_ descriptor: Action, by delta: Double) -> some View {
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
    
    private var keypadSheet: some View {
        NavigationStack {
            VStack(spacing: 32) {
                ValueLabel(text: draft.isEmpty ? text : draft, suffix: suffix, value: value)
                
                DecimalKeypad(text: $draft, fractionLength: fractionLength, upperBound: range.upperBound)
                    .padding(.horizontal)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(.confirm) {
                        let parsedDraft = Double(draft.replacingOccurrences(of: Locale.currentDecimalSeparator, with: "."))
                        
                        if let parsedDraft {
                            value = clamped(parsedDraft)
                            showKeypad = false
                        }
                    }
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button(.cancel) {
                        showKeypad = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    private var text: String {
        value.formatted(.number.precision(.fractionLength(fractionLength)))
    }
    
    private func clamped(_ raw: Double) -> Double {
        min(max(raw, range.lowerBound), range.upperBound)
    }
}

private struct ValueLabel: View {
    let text: String
    let suffix: LocalizedStringResource?
    let value: Double
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text(text)
                .font(.title)
                .fontWeight(.semibold)
                .contentTransition(.numericText(value: value))
            
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

private struct DecimalKeypad: View {
    @Binding var text: String
    
    let fractionLength: Int
    let upperBound: Double
    
    init(text: Binding<String>, fractionLength: Int = 1, upperBound: Double = 1_000_000_000) {
        self._text = text
        self.fractionLength = fractionLength
        self.upperBound = upperBound
    }
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
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
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .contentShape(.rect)
        }
        .buttonStyle(.glass)
    }
}

private extension Locale {
    static var currentDecimalSeparator: String {
        current.decimalSeparator ?? "."
    }
}

#Preview("Decimal") {
    @Previewable @State var value: Double = 0
    NumberStepper(value: $value, title: .exerciseTypeWeightTitle, suffix: .unitKilogramsSuffix)
}

#Preview("Integer") {
    @Previewable @State var value: Int = 0
    NumberStepper(value: $value, title: .fieldExerciseTargetRepsTitle)
}
