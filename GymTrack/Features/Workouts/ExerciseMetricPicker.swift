//
//  ExerciseMetricPicker.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import SwiftUI

struct ExerciseMetricPicker: View {
    @Binding var selection: ExerciseMetric

    var body: some View {
        Picker(ActionDescriptor.metric.title, selection: $selection) {
            ForEach(ExerciseMetric.allCases) { metric in
                Label(metric.title, systemImage: metric.systemImage)
                    .tag(metric)
            }
        }
    }
}

struct ExerciseTargetMetricPicker: View {
    @Binding var target: ExerciseTarget

    var body: some View {
        ExerciseMetricPicker(selection: metric)
    }

    private var metric: Binding<ExerciseMetric> {
        Binding {
            target.metric
        } set: { metric in
            withAnimation(.snappy(duration: 0.25)) {
                target = .defaults(for: metric)
            }
        }
    }
}

#Preview {
    ExerciseMetricPicker(selection: .constant(ExerciseMetric.weight))
}
