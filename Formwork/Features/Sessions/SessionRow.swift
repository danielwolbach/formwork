//
//  SessionRow.swift
//  Formwork
//
//  Created by Daniel Wolbach on 29.09.26.
//

import FormworkKit
import SwiftData
import SwiftUI

struct SessionRow: View {
    private let session: Session

    @Environment(\.modelContext)
    private var context: ModelContext

    @State
    private var deleteAlert: Bool = false

    init(_ session: Session) {
        self.session = session
    }

    var body: some View {
        NavigationLink(value: session) {
            HStack {
                DisplayableRow(session)

                Image(systemName: "chevron.forward")
                    .foregroundStyle(.tertiary)
            }
            .padding(8)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .swipeActions {
            // No destructive role: it makes SwiftUI expect the row to disappear, so cancelling the alert leaves the button stuck.
            Button(Action.delete.title, systemImage: Action.delete.image) {
                deleteAlert = true
            }
            .tint(.red)
            .labelStyle(.fixedIconOnly)
        }
        .contextMenu {
            Section {
                Button(.delete) {
                    deleteAlert = true
                }
            }
        } preview: {
            let summary = session.summary()

            VStack(spacing: 16) {
                DisplayableRow(session)

                TileGrid {
                    MetricCard(summary.duration)

                    MetricCard(summary.endTime)

                    MetricCard(summary.skipRate)

                    MetricCard(summary.medianExerciseDuration)

                    MetricCard(summary.completedExercises)

                    MetricCard(summary.totalVolume)
                }
            }
            .frame(width: 360)
            .padding()
        }
        .alert(.alertDeleteSessionTitle, isPresented: $deleteAlert) {
            Button(.cancel) {
                // Works automatically.
            }

            Button(.delete) {
                delete()
            }
        } message: {
            Text(.alertDeleteSessionMessage)
        }
        .padding(.horizontal, 8)
    }

    private func delete() {
        context.delete(session)
    }
}

#Preview {
    NavigationStack {
        SessionRow(Samples.sessions.first!)
    }
    .sampleData()
}
