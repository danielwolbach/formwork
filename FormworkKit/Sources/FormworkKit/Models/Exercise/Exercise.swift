//
//  Exercise.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import Foundation
import SwiftData

@Model
public final class Exercise {
    public var name: String = String(localized: .exerciseUnknownTitle)

    public var type: ExerciseType = ExerciseType.weight

    public var categories: Set<ExerciseCategory> = [ExerciseCategory.other]

    public var link: URL?

    public var notes: String = ""

    public var creationDate: Date = Date.now

    @Relationship(deleteRule: .cascade, inverse: \WorkoutEntry.exercise)
    public var workoutEntries: [WorkoutEntry] = []

    @Relationship(deleteRule: .nullify, inverse: \SessionEntry.exercise)
    public var sessionEntries: [SessionEntry] = []

    public init(name: String, type: ExerciseType, categories: Set<ExerciseCategory>, link: URL? = nil, notes: String = "") {
        self.name = name
        self.type = type
        self.categories = categories
        self.link = link
        self.notes = notes
        self.creationDate = .now
    }
}

extension Exercise {
    public var currentHighestTarget: ExerciseTarget? {
        workoutEntries
            .filter { $0.target.type == type }
            .max { $0.target.rank < $1.target.rank }?
            .target
    }

    public static func countTitle(_ count: Int) -> LocalizedStringResource {
        .exerciseCountTitle(count)
    }
}

extension Exercise: Displayable {
    public var pictogram: Pictogram {
        type.pictogram
    }

    public var title: String {
        name
    }

    public var subtitle: String? {
        let titles = ExerciseCategory.allCases.filter { categories.contains($0) }.map(\.title)
        return titles.isEmpty ? nil : titles.formatted(.list(type: .and, width: .narrow))
    }
}
