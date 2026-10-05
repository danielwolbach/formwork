//
//  ExerciseTargetEditor.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import FormworkKit
import FormworkUI
import SwiftUI

struct ExerciseTargetEditor: View {
    @Binding
    private var target: ExerciseTarget

    @Environment(\.units)
    private var units: Units

    init(target: Binding<ExerciseTarget>) {
        self._target = target
    }

    var body: some View {
        switch target {
        case .weight: weightTargetEditor
        case .bodyweight: bodyweightTargetEditor
        case .duration: durationTargetEditor
        case .distance: distanceTargetEditor
        }
    }

    private var weightTargetEditor: some View {
        VStack(spacing: .sections) {
            NumberStepper(
                target.title,
                value: weight,
                suffix: units.weightUnit.symbol,
                stepSize: weightStep,
                fractionLength: 1,
                range: 0 ... weightLimit
            )

            HStack(spacing: .groups) {
                NumberStepper(.fieldSetsTitle, value: $target.sets, range: 1 ... 100)

                Divider()
                    .frame(height: 48)

                NumberStepper(.fieldRepsTitle, value: $target.reps)
            }
        }
    }

    private var bodyweightTargetEditor: some View {
        VStack(spacing: .sections) {
            NumberStepper(target.title, value: $target.reps, suffix: String(localized: .fieldRepsUnit), stepSize: 1)

            NumberStepper(.fieldSetsTitle, value: $target.sets, range: 1 ... 100)
        }
    }

    private var durationTargetEditor: some View {
        VStack(spacing: .sections) {
            NumberStepper(
                target.title,
                value: minutes,
                suffix: UnitDuration.minutes.symbol,
                stepSize: minuteStep,
                fractionLength: 0,
                range: 0 ... 1440
            )

            NumberStepper(.fieldSetsTitle, value: $target.sets, range: 1 ... 100)
        }
    }

    private var distanceTargetEditor: some View {
        VStack(spacing: .sections) {
            NumberStepper(
                target.title,
                value: distance,
                suffix: units.distanceUnit.symbol,
                stepSize: distanceStep,
                fractionLength: 2,
                range: 0 ... 1000
            )

            NumberStepper(.fieldSetsTitle, value: $target.sets, range: 1 ... 100)
        }
    }

    private var weight: Binding<Double> {
        let factor = Measurement(value: 1, unit: units.weightUnit).converted(to: .kilograms).value

        return Binding(
            get: {
                target.kilograms / factor
            },
            set: {
                target.kilograms = $0 * factor
            }
        )
    }

    private var weightStep: Double {
        switch units.weight {
        case .metric: 2.5
        case .imperial: 5
        }
    }

    private var weightLimit: Double {
        switch units.weight {
        case .metric: 1000
        case .imperial: 2000
        }
    }

    private var minutes: Binding<Double> {
        Binding(
            get: {
                Double(target.seconds) / 60
            },
            set: {
                target.seconds = Int(($0 * 60).rounded())
            }
        )
    }

    private var minuteStep: Double {
        target.seconds < 60 * 10 ? 1 : (target.seconds < 60 * 60 ? 5 : 15)
    }

    private var distance: Binding<Double> {
        let factor = Measurement(value: 1, unit: units.distanceUnit).converted(to: .meters).value

        return Binding(
            get: {
                Double(target.meters) / factor
            },
            set: {
                target.meters = Int(($0 * factor).rounded())
            }
        )
    }

    private var distanceStep: Double {
        switch units.distance {
        case .metric: 0.1
        case .imperial: 0.25
        }
    }
}

extension ExerciseTarget {
    fileprivate var sets: Int {
        get {
            switch self {
            case let .weight(_, _, sets), let .bodyweight(_, sets),
                 let .duration(_, sets), let .distance(_, sets):
                sets
            }
        }
        set {
            switch self {
            case let .weight(kilograms, reps, _): self = .weight(kilograms: kilograms, reps: reps, sets: newValue)
            case let .bodyweight(reps, _): self = .bodyweight(reps: reps, sets: newValue)
            case let .duration(seconds, _): self = .duration(seconds: seconds, sets: newValue)
            case let .distance(meters, _): self = .distance(meters: meters, sets: newValue)
            }
        }
    }

    fileprivate var reps: Int {
        get {
            switch self {
            case let .weight(_, reps, _), let .bodyweight(reps, _): reps
            default: 0
            }
        }
        set {
            switch self {
            case let .weight(kilograms, _, sets): self = .weight(kilograms: kilograms, reps: newValue, sets: sets)
            case let .bodyweight(_, sets): self = .bodyweight(reps: newValue, sets: sets)
            default: break
            }
        }
    }

    fileprivate var kilograms: Double {
        get {
            if case let .weight(kilograms, _, _) = self {
                kilograms
            } else {
                0
            }
        }
        set {
            if case let .weight(_, reps, sets) = self {
                self = .weight(kilograms: newValue, reps: reps, sets: sets)
            }
        }
    }

    fileprivate var seconds: Int {
        get {
            if case let .duration(seconds, _) = self {
                seconds
            } else {
                0
            }
        }
        set {
            if case let .duration(_, sets) = self {
                self = .duration(seconds: newValue, sets: sets)
            }
        }
    }

    fileprivate var meters: Int {
        get {
            if case let .distance(meters, _) = self {
                meters
            } else {
                0
            }
        }
        set {
            if case let .distance(_, sets) = self {
                self = .distance(meters: newValue, sets: sets)
            }
        }
    }
}

#Preview("Weight") {
    @Previewable @State
    var target: ExerciseTarget = .weight()

    ExerciseTargetEditor(target: $target)
}

#Preview("Bodyweight") {
    @Previewable @State
    var target: ExerciseTarget = .bodyweight()

    ExerciseTargetEditor(target: $target)
}

#Preview("Duration") {
    @Previewable @State
    var target: ExerciseTarget = .duration()

    ExerciseTargetEditor(target: $target)
}

#Preview("Distance") {
    @Previewable @State
    var target: ExerciseTarget = .distance()

    ExerciseTargetEditor(target: $target)
}
