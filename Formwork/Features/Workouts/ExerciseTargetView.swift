//
//  ExerciseTargetView.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import SwiftUI

struct ExerciseTargetView: View {
    @Binding var target: ExerciseTarget
    
    var body: some View {
        switch target {
        case let .weight(weight, sets, reps): WeightTargetView(
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
        case let .bodyweight(sets, reps): BodyweightTargetView(
            sets: binding(
                get: { sets },
                set: { .bodyweight(sets: $0, reps: reps) }
            ),
            reps: binding(
                get: { reps },
                set: { .bodyweight(sets: sets, reps: $0) }
            )
        )
        case let .duration(minutes): DurationTargetView(
            minutes: binding(
                get: { minutes },
                set: { .duration(minutes: $0) }
            )
        )
        case let .distance(meters): DistanceTargetView(
            meters: binding(
                get: { meters },
                set: { .distance(meters: $0) }
            )
        )
        }
    }
    
    private func binding<Value: Sendable>(get: @Sendable @escaping () -> Value, set: @escaping (Value) -> ExerciseTarget) -> Binding<Value> {
        Binding(get: get, set: { target = set($0) })
    }
}

private struct WeightTargetView: View {
    @Binding var weight: Double
    @Binding var sets: Int
    @Binding var reps: Int
    
    var body: some View {
        VStack(spacing: 32) {
            NumberStepper(
                value: $weight,
                title: .exerciseTypeWeightTitle,
                suffix: .unitKilogramsSuffix,
                stepSize: 5,
                range: 0 ... 1_000,
            )
            
            BodyweightTargetView(sets: $sets, reps: $reps)
        }
    }
}

private struct BodyweightTargetView: View {
    @Binding var sets: Int
    @Binding var reps: Int
    
    var body: some View {
        VStack(spacing: 32) {
            HStack {
                NumberStepper(
                    value: $sets,
                    title: .fieldExerciseTargetSetsTitle,
                    range: 1 ... 1_000
                )
                
                Divider()
                    .frame(height: 48)
                
                NumberStepper(
                    value: $reps,
                    title: .fieldExerciseTargetRepsTitle,
                    range: 1 ... 1_000_000
                )
            }
        }
    }
}

private struct DurationTargetView: View {
    @Binding var minutes: Int
    
    var body: some View {
        VStack(spacing: 32) {
            HStack {
                NumberStepper(
                    value: $minutes,
                    title: .exerciseTypeDurationTitle,
                    suffix: .unitMinutesSuffix,
                    stepSize: 10,
                    range: 0 ... 1_000_000
                )
            }
        }
    }
}

private struct DistanceTargetView: View {
    @Binding var meters: Int
    
    var body: some View {
        VStack(spacing: 32) {
            HStack {
                NumberStepper(
                    value: $meters,
                    title: .exerciseTypeDistanceTitle,
                    suffix: .unitMetersSuffix,
                    stepSize: 100,
                    range: 0 ... 1_000_000
                )
            }
        }
    }
}

#Preview("Weight") {
    @Previewable @State var target = ExerciseTarget.weight(weight: 50, sets: 3, reps: 10)
    ExerciseTargetView(target: $target)
}

#Preview("Bodyweight") {
    @Previewable @State var target = ExerciseTarget.bodyweight(sets: 1, reps: 20)
    ExerciseTargetView(target: $target)
}

#Preview("Duration") {
    @Previewable @State var target = ExerciseTarget.duration(minutes: 10)
    ExerciseTargetView(target: $target)
}

#Preview("Distance") {
    @Previewable @State var target = ExerciseTarget.distance(meters: 500)
    ExerciseTargetView(target: $target)
}
