//
//  DateButton.swift
//  FormworkUI
//
//  Created by Daniel Wolbach on 26.09.26.
//

import SwiftUI

public struct DateButton: View {
    private let title: String

    private let components: DatePickerComponents

    @Binding
    private var date: Date

    @State
    private var isPresented: Bool = false

    public init(_ title: String, date: Binding<Date>, components: DatePickerComponents) {
        self.title = title
        self.components = components
        self._date = date
    }

    public init(_ title: LocalizedStringResource, date: Binding<Date>, components: DatePickerComponents) {
        self.init(String(localized: title), date: date, components: components)
    }

    public var body: some View {
        Button(formattedDate) {
            isPresented = true
        }
        .buttonStyle(.card)
        .popover(isPresented: $isPresented) {
            Group {
                if components == .date {
                    DatePicker(title, selection: $date, displayedComponents: components)
                        .datePickerStyle(.graphical)
                        .frame(minWidth: 320)
                } else {
                    DatePicker(title, selection: $date, displayedComponents: components)
                        .datePickerStyle(.wheel)
                }
            }
            .labelsHidden()
            .padding()
            .presentationCompactAdaptation(.popover)
        }
        .accessibilityLabel(title)
        .accessibilityValue(formattedDate)
    }

    private var formattedDate: String {
        components == .date
            ? date.formatted(date: .abbreviated, time: .omitted)
            : date.formatted(date: .omitted, time: .shortened)
    }
}
