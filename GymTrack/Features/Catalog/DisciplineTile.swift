//
//  DisciplineTile.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import SwiftUI

struct DisciplineTile: View {
    let discipline: Discipline
    let count: Int

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(systemName: discipline.icon)
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
                .padding(4)

            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer()

                    Text(discipline.title)
                        .font(.headline)

                    Text(.disciplineExerciseCount(count: count))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding()
        }
        .foregroundStyle(.white)
        .aspectRatio(1.8, contentMode: .fit)
        .glassEffect(.regular.tint(discipline.color), in: .rect(cornerRadius: 16, style: .continuous))
        .contentShape(Rectangle())
    }
}

#Preview {
    DisciplineTile(discipline: Discipline.arms, count: 5)
        .padding()
}
