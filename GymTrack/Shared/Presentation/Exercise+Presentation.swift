//
//  Exercise+Presentation.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import SwiftUI

extension Exercise {
    var systemImage: String {
        metric.systemImage
    }
}

extension Exercise {
    var color: Color {
        metric.color
    }
}

extension Exercise {
    var disciplinesText: Text {
        let selectedDisciplines = Discipline.allCases.filter { disciplines.contains($0) }

        guard let first = selectedDisciplines.first else {
            return Text("No Disciplines")
        }

        return selectedDisciplines.dropFirst().reduce(Text(first.title)) { text, discipline in
            Text("\(text), \(Text(discipline.title))")
        }
    }
}

extension Exercise {
    static let systemImage = "dumbbell"
}

extension Exercise {
    static let color = Color.accentColor
}
