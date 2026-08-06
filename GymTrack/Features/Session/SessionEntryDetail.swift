//
//  SessionEntryDetail.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 13.07.26.
//

import SwiftUI

struct SessionEntryDetail: View {
    @Bindable var entry: SessionEntry

    var body: some View {
        VStack(spacing: 32) {
            IconHero(icon: entry.icon, color: entry.color, title: entry.title, subtitle: entry.subtitle)

            ExerciseTargetEditor(target: $entry.target)
        }
    }
}

#Preview {
    SessionEntryDetail(entry: SessionEntry.samples[0])
        .padding()
}
