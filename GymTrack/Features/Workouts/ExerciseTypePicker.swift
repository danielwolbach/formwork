//
//  ExerciseTypePicker.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import SwiftUI

struct ExerciseTypePicker: View {
    @Binding var selection: ExerciseType

    var body: some View {
        Picker(ActionDescriptor.type.title, selection: $selection) {
            ForEach(ExerciseType.allCases) { type in
                Label(type.title, systemImage: type.icon)
                    .tag(type)
            }
        }
    }
}

#Preview {
    ExerciseTypePicker(selection: .constant(ExerciseType.weight))
}
