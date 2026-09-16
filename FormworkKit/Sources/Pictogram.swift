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

public extension Pictogram {
    nonisolated enum Tint: String, Identifiable, Codable, Hashable, Sendable, CaseIterable {
        case blue
        case indigo
        case purple
        case pink
        case red
        case orange
        case yellow
        case green
        case mint
        case cyan
        case brown
        case gray

        public var id: Self {
            self
        }

        public var color: Color {
            switch self {
            case .gray: .gray
            case .red: .red
            case .orange: .orange
            case .yellow: .yellow
            case .green: .green
            case .mint: .mint
            case .cyan: .cyan
            case .blue: .blue
            case .indigo: .indigo
            case .purple: .purple
            case .pink: .pink
            case .brown: .brown
            }
        }
    }

    static let unknown = Pictogram(icon: "questionmark", tint: .gray)
    static let workout = Pictogram(icon: "figure.strengthtraining.traditional", tint: .blue)

    static let duration = Pictogram(icon: "stopwatch", tint: .cyan)
    static let date = Pictogram(icon: "calendar", tint: .indigo)
    static let time = Pictogram(icon: "clock", tint: .blue)
    static let tally = Pictogram(icon: "repeat", tint: .orange)
    static let record = Pictogram(icon: "trophy", tint: .yellow)
    static let streak = Pictogram(icon: "flame", tint: .orange)
    static let month = Pictogram(icon: "calendar.badge.checkmark", tint: .mint)
    static let completed = Pictogram(icon: "checkmark.circle", tint: .green)
    static let skipped = Pictogram(icon: "forward.end", tint: .pink)
}
