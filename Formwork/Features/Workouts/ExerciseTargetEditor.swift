//
//  ExerciseTargetEditor.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import FormworkKit
import SwiftUI

struct ExerciseTargetEditor: View {
    @Binding
    var target: ExerciseTarget

    var body: some View {
        switch target {
        case let .weight(weight):
            WeightTargetEditor(target: Binding(get: { weight }, set: { target = .weight(target: $0) }))
        case let .bodyweight(bodyweight):
            BodyweightTargetEditor(target: Binding(get: { bodyweight }, set: { target = .bodyweight(target: $0) }))
        case let .duration(duration):
            DurationTargetEditor(target: Binding(get: { duration }, set: { target = .duration(target: $0) }))
        case let .distance(distance):
            DistanceTargetEditor(target: Binding(get: { distance }, set: { target = .distance(target: $0) }))
        }
    }
}

private struct WeightTargetEditor: View {
    @Binding
    var target: ExerciseTarget.WeightTarget

    var body: some View {
        VStack(spacing: 32) {
            NumberStepper(
                value: $target.weight.value,
                title: ExerciseType.weight.title,
                suffix: target.symbol,
                stepSize: target.stepSize,
                fractionLength: target.fractionLength,
                range: target.range
            )

            HStack {
                NumberStepper(
                    value: $target.sets,
                    title: String(localized: .fieldSetsTitle),
                    range: 1 ... 1000
                )

                Divider()
                    .frame(height: 48)

                NumberStepper(
                    value: $target.reps,
                    title: String(localized: .fieldRepsTitle),
                    range: 1 ... 1_000_000
                )
            }
        }
    }
}

private struct BodyweightTargetEditor: View {
    @Binding
    var target: ExerciseTarget.BodyweightTarget

    var body: some View {
        VStack(spacing: 32) {
            NumberStepper(
                value: $target.reps,
                title: ExerciseType.bodyweight.title,
                suffix: target.symbol,
                stepSize: target.stepSize,
                range: target.range
            )

            NumberStepper(
                value: $target.sets,
                title: String(localized: .fieldSetsTitle),
                range: 1 ... 1000
            )
        }
    }
}

private struct DurationTargetEditor: View {
    @Binding
    var target: ExerciseTarget.DurationTarget

    var body: some View {
        NumberStepper(
            value: $target.duration.value,
            title: ExerciseType.duration.title,
            suffix: target.symbol,
            stepSize: target.stepSize,
            fractionLength: target.fractionLength,
            range: target.range
        )
    }
}

private struct DistanceTargetEditor: View {
    @Binding
    var target: ExerciseTarget.DistanceTarget

    var body: some View {
        NumberStepper(
            value: $target.distance.value,
            title: ExerciseType.distance.title,
            suffix: target.symbol,
            stepSize: target.stepSize,
            fractionLength: target.fractionLength,
            range: target.range
        )
    }
}

#Preview("Weight") {
    @Previewable
    @State
    var target = ExerciseTarget.weight(target: .init(weight: Quantity(50, in: .kilograms), sets: 3, reps: 10))
    ExerciseTargetEditor(target: $target)
}

#Preview("Bodyweight") {
    @Previewable
    @State
    var target = ExerciseTarget.bodyweight(target: .init(sets: 1, reps: 20))
    ExerciseTargetEditor(target: $target)
}

#Preview("Duration") {
    @Previewable
    @State
    var target = ExerciseTarget.duration(target: .init(duration: Quantity(10, in: .minutes)))
    ExerciseTargetEditor(target: $target)
}

#Preview("Distance") {
    @Previewable
    @State
    var target = ExerciseTarget.distance(target: .init(distance: Quantity(500, in: .meters)))
    ExerciseTargetEditor(target: $target)
}
