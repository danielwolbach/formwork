//
//  ReadingAxis.swift
//  Formwork
//
//  Created by Daniel Wolbach on 02.10.26.
//

import Charts
import FormworkKit
import FormworkUI
import SwiftUI

extension View {
    func readingAxis(upTo peak: Double, reading: @escaping (Double) -> Reading?) -> some View {
        modifier(ReadingAxis(peak: peak, reading: reading))
    }
}

struct ReadingAxis: ViewModifier {
    private static let durationSteps: [Double] = [15, 30, 60, 120, 300, 600, 900, 1800, 3600, 7200]

    let peak: Double

    let reading: (Double) -> Reading?

    @Environment(\.units)
    private var units: Units

    static func step(upTo peak: Double, count: Int = 4, reading: (Double) -> Reading?) -> Double? {
        guard peak > 0, case .duration? = reading(peak) else {
            return nil
        }

        return durationSteps.first { (peak / $0).rounded(.up) <= Double(count) } ?? durationSteps.last
    }

    func body(content: Content) -> some View {
        let step = Self.step(upTo: peak, reading: reading)
        let axis = content.chartYAxis {
            AxisMarks(position: .leading, values: step.map { .stride(by: $0) } ?? .automatic) { mark in
                AxisGridLine()
                AxisTick()

                if let value = mark.as(Double.self), let reading = reading(value) {
                    AxisValueLabel {
                        Text(verbatim: reading.formatted(.reading(units: units)))
                    }
                }
            }
        }

        if let step {
            axis.chartYScale(domain: 0 ... step * (peak / step).rounded(.up))
        } else {
            axis
        }
    }
}
