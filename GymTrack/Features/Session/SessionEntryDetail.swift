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
            DetailHero(
                title: entry.exercise.name,
                subtitle: entry.exercise.disciplinesText,
                systemImage: entry.systemImage,
                color: entry.color
            )

            ExerciseTargetEditor(target: $entry.target)
        }
    }
}

#Preview {
    SessionEntryDetail(entry: SessionEntry.samples[0])
        .padding()
}
