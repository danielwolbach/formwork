//
//  Pictogram.swift
//  Formwork
//
//  Created by Daniel Wolbach on 06.09.26.
//

import Foundation
import SwiftUI

public struct Pictogram: Hashable, Codable, Sendable {
    public enum Tint: Codable, CaseIterable, Sendable {
        case blue, indigo, purple, pink, red, orange, yellow, green, mint, cyan, brown, gray
    }

    public var image: String

    public var tint: Tint

    public init(image: String, tint: Tint) {
        self.image = image
        self.tint = tint
    }
}

extension Pictogram.Tint: Identifiable {
    public var id: Self {
        self
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

extension Pictogram {
    public var color: Color {
        tint.color
    }
}

extension Pictogram {
    public static let unknown: Pictogram = .init(image: "questionmark", tint: .gray)

    public static let workout = Pictogram(image: "figure.strengthtraining.traditional", tint: .blue)

    public static let exercise = Pictogram(image: "figure.strengthtraining.functional", tint: .green)

    public static let duration = Pictogram(image: "stopwatch", tint: .cyan)

    public static let date = Pictogram(image: "calendar", tint: .indigo)

    public static let time = Pictogram(image: "clock", tint: .blue)

    public static let tally = Pictogram(image: "repeat", tint: .orange)

    public static let record = Pictogram(image: "trophy", tint: .yellow)

    public static let streak = Pictogram(image: "flame", tint: .orange)

    public static let frequency = Pictogram(image: "chart.bar", tint: .purple)

    public static let completed = Pictogram(image: "checkmark.circle", tint: .green)

    public static let skipped = Pictogram(image: "forward.end", tint: .pink)

    public static let pace = Pictogram(image: "hourglass", tint: .mint)

    public static let increase = Pictogram(image: "arrow.up.right", tint: .green)

    public static let decrease = Pictogram(image: "arrow.down.right", tint: .red)

    public static let volume = Pictogram(image: "scalemass", tint: .indigo)

    public static let progression = Pictogram(image: "chart.line.uptrend.xyaxis", tint: .blue)

    public static let activity = Pictogram(image: "square.grid.3x3", tint: .orange)

    public static let categories = Pictogram(image: "chart.pie", tint: .gray)

    public static let pendingBadge = Pictogram(image: "ellipsis.circle.fill", tint: .gray)

    public static let completedBadge = Pictogram(image: "checkmark.circle.fill", tint: .green)

    public static let skippedBadge = Pictogram(image: "arrowtriangle.forward.circle.fill", tint: .orange)

    public static let recordBadge = Pictogram(image: "trophy.circle.fill", tint: .yellow)

    public static let editBadge = Pictogram(image: "pencil.circle.fill", tint: .gray)

    public static let workoutImageOptions: [String] = [
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
