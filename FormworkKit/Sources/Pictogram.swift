//
//  Pictogram.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 06.09.26.
//

import SwiftUI

public nonisolated struct Pictogram: Codable, Hashable, Sendable {
    public var icon: String

    public var tint: Tint

    public init(icon: String, tint: Tint) {
        self.icon = icon
        self.tint = tint
    }

    public var color: Color {
        tint.color
    }
}

extension Pictogram {
    public nonisolated enum Tint: String, Codable, Hashable, Sendable, CaseIterable {
        case accent
        case gray
        case red
        case orange
        case yellow
        case green
        case mint
        case teal
        case cyan
        case blue
        case indigo
        case purple
        case pink
        case brown

        public var color: Color {
            switch self {
            case .accent: .accentColor
            case .gray: .gray
            case .red: .red
            case .orange: .orange
            case .yellow: .yellow
            case .green: .green
            case .mint: .mint
            case .teal: .teal
            case .cyan: .cyan
            case .blue: .blue
            case .indigo: .indigo
            case .purple: .purple
            case .pink: .pink
            case .brown: .brown
            }
        }
    }

    public static let unknown = Pictogram(icon: "questionmark", tint: .gray)
}
