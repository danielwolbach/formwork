//
//  IconAccessory.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 06.08.26.
//

import SwiftUI

struct IconAccessory: View {
    let icon: String

    var body: some View {
        Image(systemName: icon)
            .font(.title2)
            .foregroundStyle(.quaternary)
    }
}

#Preview {
    IconAccessory(icon: "chevron.right")
        .padding()
}
