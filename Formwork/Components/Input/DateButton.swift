//
//  DateButton.swift
//  Formwork
//
//  Created by Daniel Wolbach on 26.09.26.
//

import FormworkKit
import SwiftUI

struct DateButton: View {
    @Binding
    private var date: Date

    @State
    private var isPresented = false

    init(date: Binding<Date>) {
        self._date = date
    }

    var body: some View {
        Button(date.formatted(date: .abbreviated, time: .omitted)) {
            isPresented = true
        }
        .buttonStyle(.card())
        .labelStyle(.fixedTitleAndIcon)
        .popover(isPresented: $isPresented) {
            DatePicker(.placeholder, selection: $date, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .labelsHidden()
                .frame(minWidth: 320)
                .padding()
                .presentationCompactAdaptation(.popover)
        }
    }
}
