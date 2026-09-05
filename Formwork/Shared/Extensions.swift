//
//  Extensions.swift
//  Formwork
//
//  Created by Daniel Wolbach on 05.09.26.
//

import SwiftUI

extension Binding where Value == String {
    func animated() -> Binding<String> {
        Binding(
            get: { wrappedValue },
            set: { newValue in withAnimation(.snappy) { wrappedValue = newValue } }
        )
    }
}
