//
//  ChipToggleStyle.swift
//  FormworkModules
//
//  Created by Daniel Wolbach on 08.10.26.
//

import SwiftUI

public struct ChipToggleStyle: ToggleStyle {
    public func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            Label {
                configuration.label
            } icon: {
                Image(systemName: configuration.isOn ? "checkmark" : "xmark")
                    .contentTransition(.symbolEffect(.replace))
            }
            .labelStyle(.chip(tint: configuration.isOn ? .green : .red))
            .animation(.snappy, value: configuration.isOn)
        }
    }
}

extension ToggleStyle where Self == ChipToggleStyle {
    public static var chip: ChipToggleStyle {
        ChipToggleStyle()
    }
}
