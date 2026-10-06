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

extension Array where Element: Identifiable, Element.ID: Sendable {
    public mutating func apply(difference: ReorderDifference<Element.ID, some Hashable & Sendable>) {
        let moved = filter { difference.sources.contains($0.id) }
        removeAll { difference.sources.contains($0.id) }

        switch difference.destination.position {
        case let .before(id):
            guard let index = firstIndex(where: { $0.id == id }) else {
                return
            }
            insert(contentsOf: moved, at: index)
        case .end:
            append(contentsOf: moved)
        }
    }
}

extension Locale {
    public static var currentDecimalSeparator: String {
        current.decimalSeparator ?? "."
    }
}

extension CGFloat {
    public static let sections: CGFloat = 32

    public static let groups: CGFloat = 16

    public static let items: CGFloat = 8
}
