//
//  DateButton.swift
//  FormworkUI
//
//  Created by Daniel Wolbach on 26.09.26.
//

import FormworkKit
import SwiftUI

public struct DateButton: View {
    private let title: String

    @Binding
    private var date: Date

    @State
    private var isPresented = false

    public init(_ title: String, date: Binding<Date>) {
        self.title = title
        self._date = date
    }

    public init(_ title: LocalizedStringResource, date: Binding<Date>) {
        self.init(String(localized: title), date: date)
    }

    public var body: some View {
        Button(date.formatted(date: .abbreviated, time: .omitted)) {
            isPresented = true
        }
        .buttonStyle(.card)
        .labelStyle(.fixedTitleAndIcon)
        .popover(isPresented: $isPresented) {
            DatePicker(title, selection: $date, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .labelsHidden()
                .frame(minWidth: 320)
                .padding()
                .presentationCompactAdaptation(.popover)
        }
    }
}
