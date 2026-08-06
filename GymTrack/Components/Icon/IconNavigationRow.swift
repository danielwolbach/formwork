//
//  IconNavigationRow.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 06.08.26.
//

import SwiftUI

struct IconNavigationRow<Value: Hashable>: View {
    let value: Value
    let icon: String
    let color: Color
    let title: String
    let subtitle: String

    var body: some View {
        NavigationLink(value: value) {
            HStack {
                IconRow(icon: icon, color: color, title: title, subtitle: subtitle)
                IconAccessory(icon: "chevron.right")
            }
            .contentShape(.rect)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        IconNavigationRow(
            value: "preview",
            icon: "dumbbell",
            color: .orange,
            title: "Bench Press",
            subtitle: "Weight · Chest, Arms"
        )
    }
}
