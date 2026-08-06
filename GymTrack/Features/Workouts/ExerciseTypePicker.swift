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

struct ExerciseTargetTypePicker: View {
    @Binding var target: ExerciseTarget

    var body: some View {
        ExerciseTypePicker(selection: type)
    }

    private var type: Binding<ExerciseType> {
        Binding {
            target.type
        } set: { type in
            withAnimation(.snappy(duration: 0.25)) {
                target = .defaults(for: type)
            }
        }
    }
}

#Preview {
    ExerciseTypePicker(selection: .constant(ExerciseType.weight))
}

#Preview {
    @Previewable @State var target = ExerciseTarget.weight(weight: 60, sets: 3, reps: 8)

    ExerciseTargetTypePicker(target: $target)
        .padding()
}
