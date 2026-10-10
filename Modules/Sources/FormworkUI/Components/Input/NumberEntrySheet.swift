//
//  NumberEntrySheet.swift
//  FormworkUI
//
//  Created by Daniel Wolbach on 10.10.26.
//

import FormworkKit
import SwiftUI

public struct NumberEntrySheet: View {
    private let title: String

    private let suffix: String?

    private let format: NumberFormat

    private let range: ClosedRange<Double>

    @Binding
    private var value: Double

    @Environment(\.dismiss)
    private var dismiss: DismissAction

    @State
    private var draft = ""

    public init(
        _ title: String,
        value: Binding<Double>,
        suffix: String? = nil,
        fractionLength: Int = 1,
        range: ClosedRange<Double> = 0.0 ... 1000.0
    ) {
        self.init(title, value: value, suffix: suffix, format: .number(fractionLength: fractionLength), range: range)
    }

    init(_ title: String, value: Binding<Double>, suffix: String?, format: NumberFormat, range: ClosedRange<Double>) {
        self._value = value
        self.title = title
        self.suffix = suffix
        self.format = format
        self.range = range
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                ValueLabel(
                    text: draft.isEmpty ? format.format(value) : draft,
                    pendingDigits: format.pendingDigits(after: draft),
                    suffix: suffix,
                    value: value,
                    isPlaceholder: draft.isEmpty
                )

                NumberKeypad(format: format, upperBound: range.upperBound, text: $draft)
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

    private func confirm() {
        if let parsed = format.parse(draft) {
            value = min(max(parsed, range.lowerBound), range.upperBound)
        }

        dismiss()
    }
}

#Preview {
    @Previewable
    @State
    var value: Double = 80

    Color.clear
        .sheet(isPresented: .constant(true)) {
            NumberEntrySheet("Body Weight", value: $value, suffix: "kg")
        }
}
