//
//  ExerciseTargetUnitPicker.swift
//  Formwork
//
//  Created by Daniel Wolbach on 17.09.26.
//

import FormworkKit
import SwiftUI

struct ExerciseTargetUnitPicker: View {
    @Binding
    var target: ExerciseTarget

    var body: some View {
        switch target {
        case var .weight(weight):
            UnitPicker(quantity: Binding(get: { weight.weight }, set: { weight.weight = $0
                target = .weight(target: weight)
            }))
        case var .duration(duration):
            UnitPicker(quantity: Binding(get: { duration.duration }, set: { duration.duration = $0
                target = .duration(target: duration)
            }))
        case var .distance(distance):
            UnitPicker(quantity: Binding(get: { distance.distance }, set: { distance.distance = $0
                target = .distance(target: distance)
            }))
        case .bodyweight:
            EmptyView()
        }
    }
}

private struct UnitPicker: View {
    @Binding
    var quantity: Quantity

    var body: some View {
        Picker(ActionDescriptor.unit.title, selection: $quantity.unit) {
            ForEach(quantity.unit.alternatives) { candidate in
                Text(candidate.name).tag(candidate)
            }
        }
    }
}

#Preview("Weight") {
    @Previewable
    @State
    var target = ExerciseTarget.weight(target: .init(weight: .defaultWeight, sets: 3, reps: 10))
    ExerciseTargetUnitPicker(target: $target)
}

#Preview("Duration") {
    @Previewable
    @State
    var target = ExerciseTarget.duration(target: .init(duration: .defaultDuration))
    ExerciseTargetUnitPicker(target: $target)
}

#Preview("Distance") {
    @Previewable
    @State
    var target = ExerciseTarget.distance(target: .init(distance: .defaultDistance))
    ExerciseTargetUnitPicker(target: $target)
}
