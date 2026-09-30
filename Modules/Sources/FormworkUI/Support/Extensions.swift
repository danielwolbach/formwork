//
//  Extensions.swift
//  FormworkUI
//
//  Created by Daniel Wolbach on 20.09.26.
//

import FormworkKit
import SwiftData
import SwiftUI

extension Pictogram {
    public var color: Color {
        tint.color
    }
}

extension Pictogram.Tint {
    public var color: Color {
        switch self {
        case .blue: .blue
        case .indigo: .indigo
        case .purple: .purple
        case .pink: .pink
        case .red: .red
        case .orange: .orange
        case .yellow: .yellow
        case .green: .green
        case .mint: .mint
        case .cyan: .cyan
        case .brown: .brown
        case .gray: .gray
        }
    }
}

extension View {
    public func sampleData() -> some View {
        modelContainer(Samples.container)
    }
}

extension Locale {
    public static var currentDecimalSeparator: String {
        current.decimalSeparator ?? "."
    }
}
