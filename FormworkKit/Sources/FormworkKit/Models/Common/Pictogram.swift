//
//  Pictogram.swift
//  Formwork
//
//  Created by Daniel Wolbach on 06.09.26.
//

import Foundation
import SwiftUI

public struct Pictogram: Hashable, Codable, Sendable {
    public var image: String
    public var tint: Tint

    public init(image: String, tint: Tint) {
        self.image = image
        self.tint = tint
    }

    public var color: Color {
        tint.color
    }
}

public extension Pictogram {
    enum Tint: Identifiable, Codable, CaseIterable, Sendable {
        case blue, indigo, purple, pink, red, orange, yellow, green, mint, cyan, brown, gray

        public var id: Self {
            self
        }

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
}

public extension Pictogram {
    static let unknown: Pictogram = .init(image: "questionmark", tint: .gray)
    static let workout = Pictogram(image: "figure.strengthtraining.traditional", tint: .blue)
    static let duration = Pictogram(image: "stopwatch", tint: .cyan)
    static let date = Pictogram(image: "calendar", tint: .indigo)
    static let time = Pictogram(image: "clock", tint: .blue)
    static let tally = Pictogram(image: "repeat", tint: .orange)
    static let record = Pictogram(image: "trophy", tint: .yellow)
    static let streak = Pictogram(image: "flame", tint: .orange)
    static let frequency = Pictogram(image: "chart.bar", tint: .purple)
    static let completed = Pictogram(image: "checkmark.circle", tint: .green)
    static let skipped = Pictogram(image: "forward.end", tint: .pink)
    static let pace = Pictogram(image: "hourglass", tint: .mint)
    static let increase = Pictogram(image: "arrow.up.right", tint: .green)
    static let decrease = Pictogram(image: "arrow.down.right", tint: .red)
    static let volume = Pictogram(image: "scalemass", tint: .indigo)
    static let progression = Pictogram(image: "chart.line.uptrend.xyaxis", tint: .blue)
    static let activity = Pictogram(image: "square.grid.3x3", tint: .orange)
    static let categories = Pictogram(image: "chart.pie", tint: .gray)
}

public extension Pictogram {
    static let pendingBadge = Pictogram(image: "ellipsis.circle.fill", tint: .gray)
    static let completedBadge = Pictogram(image: "checkmark.circle.fill", tint: .green)
    static let skippedBadge = Pictogram(image: "arrowtriangle.forward.circle.fill", tint: .orange)
    static let recordBadge = Pictogram(image: "trophy.circle.fill", tint: .yellow)
    static let editBadge = Pictogram(image: "pencil.circle.fill", tint: .gray)
}

public extension Pictogram {
    static let workoutImageOptions: [String] = [
        Pictogram.workout.image,
        "figure",
        "figure.walk",
        "figure.run",
        "figure.barre",
        "figure.boxing",
        "figure.cooldown",
        "figure.dance",
        "figure.flexibility",
        "figure.gymnastics",
        "figure.jumprope",
        "figure.pilates",
        "figure.play",
        "figure.rolling",
        "figure.yoga",
        "figure.cross.training",
        "figure.strengthtraining.functional",
        "figure.highintensity.intervaltraining",
        "figure.martial.arts",
        "figure.indoor.rowing",
        "figure.step.training",
        "figure.run.treadmill",
        "figure.indoor.cycle",
        "figure.stair.stepper",
    ]
}
