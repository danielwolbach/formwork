//
//  ExerciseTargetEditor.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import SwiftUI

struct ExerciseTargetEditor: View {
    @Binding var target: ExerciseTarget

    var body: some View {
        ZStack {
            editor
                .id(target.metric)
                .transition(.opacity.combined(with: .scale(scale: 0.98)))
        }
        .animation(.snappy(duration: 0.25), value: target.metric)
    }

    @ViewBuilder
    private var editor: some View {
        switch target {
        case let .weight(weight, sets, reps):
            WeightTargetEditor(
                weight: binding(
                    get: { weight },
                    set: { .weight(weight: $0, sets: sets, reps: reps) }
                ),
                sets: binding(
                    get: { sets },
                    set: { .weight(weight: weight, sets: $0, reps: reps) }
                ),
                reps: binding(
                    get: { reps },
                    set: { .weight(weight: weight, sets: sets, reps: $0) }
                )
            )
        case let .bodyweight(sets, reps):
            SetsRepsTargetEditor(
                sets: binding(
                    get: { sets },
                    set: { .bodyweight(sets: $0, reps: reps) }
                ),
                reps: binding(
                    get: { reps },
                    set: { .bodyweight(sets: sets, reps: $0) }
                )
            )
        case let .duration(minutes):
            NumberStepper(
                value: binding(
                    get: { minutes },
                    set: { .duration(minutes: $0) }
                ),
                title: "Minutes",
                step: 5,
                suffix: "min"
            )
        case let .distance(meters):
            NumberStepper(
                value: binding(
                    get: { meters },
                    set: { .distance(meters: $0) }
                ),
                title: "Meters",
                step: 100,
                suffix: "m"
            )
        }
    }

    private func binding<Value>(
        get: @escaping () -> Value,
        set: @escaping (Value) -> ExerciseTarget
    ) -> Binding<Value> {
        Binding(
            get: get,
            set: { target = set($0) }
        )
    }
}

private struct WeightTargetEditor: View {
    @Binding var weight: Double
    @Binding var sets: Int
    @Binding var reps: Int

    var body: some View {
        VStack(spacing: 24) {
            NumberStepper(value: $weight, title: "Weight", step: 5, suffix: "kg")
            SetsRepsTargetEditor(sets: $sets, reps: $reps)
        }
    }
}

private struct SetsRepsTargetEditor: View {
    @Binding var sets: Int
    @Binding var reps: Int

    var body: some View {
        HStack(spacing: 24) {
            NumberStepper(value: $sets, title: "Sets")

            Divider()
                .frame(height: 48)

            NumberStepper(value: $reps, title: "Reps")
        }
    }
}

#Preview("Weight") {
    @Previewable @State var target = ExerciseTarget.weight(weight: 60, sets: 3, reps: 10)

    ExerciseTargetEditor(target: $target)
        .padding()
}

#Preview("Bodyweight") {
    @Previewable @State var target = ExerciseTarget.bodyweight(sets: 3, reps: 10)

    ExerciseTargetEditor(target: $target)
        .padding()
}

#Preview("Duration") {
    @Previewable @State var target = ExerciseTarget.duration(minutes: 10)

    ExerciseTargetEditor(target: $target)
        .padding()
}

#Preview("Distance") {
    @Previewable @State var target = ExerciseTarget.distance(meters: 1000)

    ExerciseTargetEditor(target: $target)
        .padding()
}
