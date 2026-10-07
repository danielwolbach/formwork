//
//  DebugMenu.swift
//  Formwork
//
//  Created by Daniel Wolbach on 21.09.26.
//

import FormworkKit
import FormworkUI
import SwiftData
import SwiftUI

struct DebugMenu: View {
    @Environment(\.modelContext)
    private var modelContext: ModelContext

    @Environment(\.presentPaywall)
    private var presentPaywall: PresentPaywallAction

    @AppStorage(StorageKeys.onboardingPending)
    private var onboardingPending: Bool = true

    var body: some View {
        #if DEBUG
            Menu(.debug) {
                Button(String("Restart Onboarding"), systemImage: "arrow.counterclockwise") {
                    onboardingPending = true
                }

                Button(String("Show Paywall"), systemImage: "lock.open") {
                    presentPaywall()
                }

                Button(String("Insert Sample Data"), systemImage: "tray.and.arrow.down") {
                    Samples.insert(into: modelContext)
                }

                Button(String("Unarchive All"), systemImage: "archivebox") {
                    unarchiveAll()
                }

                Button(String("Delete Everything"), systemImage: "trash", role: .destructive) {
                    Storage.deleteEverything(in: modelContext)
                }
            }
        #else
            EmptyView()
        #endif
    }

    #if DEBUG
        private func unarchiveAll() {
            let exercises = (try? modelContext.fetch(FetchDescriptor<Exercise>(predicate: #Predicate { $0.isArchived }))) ?? []
            let workouts = (try? modelContext.fetch(FetchDescriptor<Workout>(predicate: #Predicate { $0.isArchived }))) ?? []

            for exercise in exercises {
                exercise.isArchived = false
            }

            for workout in workouts {
                workout.isArchived = false
            }
        }
    #endif
}
