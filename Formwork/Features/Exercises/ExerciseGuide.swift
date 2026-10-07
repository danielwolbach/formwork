//
//  ExerciseGuide.swift
//  Formwork
//
//  Created by Daniel Wolbach on 25.09.26.
//

import FormworkKit
import FormworkUI
import SwiftUI

struct ExerciseGuide: View {
    private let exercise: Exercise

    @Environment(\.openURL)
    private var openURL: OpenURLAction

    @State
    private var sheet: Sheet?

    init(_ exercise: Exercise) {
        self.exercise = exercise
    }

    var body: some View {
        VStack(spacing: .items) {
            if let link = exercise.link {
                Link(destination: link) {
                    GroupBox {
                        HStack {
                            if let host = link.host().map({ String($0.trimmingPrefix("www.")) }) {
                                Text(host)
                                    .font(.headline)
                                    .lineLimit(1)
                            }

                            Spacer(minLength: 0)

                            Image(systemName: "arrow.up.right")
                                .foregroundStyle(.tertiary)
                                .accessibilityHidden(true)
                        }
                    } label: {
                        Label(.fieldLinkTitle, systemImage: "link")
                    }
                }
                .buttonStyle(.plain)
            }

            Button {
                sheet = .editExerciseNotes(exercise)
            } label: {
                GroupBox {
                    Text(exercise.notes.isEmpty ? String(localized: .fieldNotesPlaceholder) : exercise.notes)
                        .foregroundStyle(exercise.notes.isEmpty ? .tertiary : .primary)
                        .lineLimit(4...)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } label: {
                    Label(.fieldNotesTitle, systemImage: "document")
                }
            }
            .buttonStyle(.plain)
        }
        .groupBoxStyle(.card)
        .sheet(item: $sheet) { sheet in
            sheet
        }
    }
}

#Preview {
    ExerciseGuide(Samples.exercises[1])
        .padding()
}
