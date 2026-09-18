//
//  Extensions.swift
//  Formwork
//
//  Created by Daniel Wolbach on 05.09.26.
//

import FormworkKit
import SwiftData
import SwiftUI

extension Binding where Value == String {
    func animated() -> Binding<String> {
        Binding(
            get: { wrappedValue },
            set: { newValue in withAnimation(.snappy) { wrappedValue = newValue } }
        )
    }
}

extension GridItem {
    static func ntile(n: Int, spacing: CGFloat? = nil) -> [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: spacing), count: n)
    }
}

extension Locale {
    static var currentDecimalSeparator: String {
        current.decimalSeparator ?? "."
    }
}
