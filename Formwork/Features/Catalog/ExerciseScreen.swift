//
//  ExerciseScreen.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import FormworkKit
import SwiftData
import SwiftUI

struct ExerciseScreen: View {
    @Environment(\.modelContext) private var modelContext: ModelContext
    @Environment(\.dismiss) private var dismiss: DismissAction
    @Query(Session.finishedDescriptor) private var sessions: [Session]
    @State private var sheet: Sheet? = nil
    @State private var deleteAlert: Bool = false
    
    let exercise: Exercise
    
    var body: some View {
        let statistics = sessions.statistics()[exercise]
        
        ScrollView {
            VStack(spacing: 32) {
                DisplayableHero(displayable: exercise)
                
                LazyVGrid(columns: [.init(.flexible()), .init(.flexible())]) {
                    ValueCard(
                        title: .statisticPersonalBestTitle,
                        value: statistics.personalBest?.measure,
                        pictogram: .init(icon: "trophy", tint: .yellow)
                    )
                    
                    ValueCard(
                        title: .statisticCompletionRateTitle,
                        value: statistics.completionRate?.formatted(.percent.precision(.fractionLength(0))),
                        pictogram: .init(icon: "checkmark.circle", tint: .green)
                    )
                    
                    ValueCard(
                        title: .statisticLastPerformedTitle,
                        value: statistics.lastCompleted?.relativeDayDescription().localizedCapitalized,
                        pictogram: .init(icon: "calendar", tint: .indigo)
                    )
                    
                    ValueCard(
                        title: .statisticTimesCompletedTitle,
                        value: statistics.completions.count.formatted(),
                        pictogram: .init(icon: "repeat", tint: .orange)
                    )
                }
                .padding(.horizontal)
            }
        }
        .toolbar {
            Menu(.more) {
                Section {
                    Button(.edit) {
                        sheet = .editExercise(exercise: exercise)
                    }
                }
                
                Section {
                    Button(.delete) {
                        deleteAlert = true
                    }
                }
            }
        }
        .sheet(item: $sheet) { sheet in
            NavigationStack {
                sheet
            }
        }
        .alert(.alertExerciseDeleteTitle, isPresented: $deleteAlert) {
            Button(.delete) {
                delete()
            }
            
            Button(.cancel) {
                
            }
        } message: {
            Text(.alertExerciseDeleteMessage)
        }
    }
    
    func delete() {
        modelContext.delete(exercise)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        ExerciseScreen(exercise: Samples.exercises.first!)
    }
}
