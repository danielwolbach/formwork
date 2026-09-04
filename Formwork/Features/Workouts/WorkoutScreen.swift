//
//  WorkoutScreen.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import SwiftData
import SwiftUI

struct WorkoutScreen: View {
    @Environment(\.modelContext) private var modelContext: ModelContext
    @Environment(\.dismiss) private var dismiss: DismissAction
    @State private var sheet: Sheet? = nil
    @State private var deleteAlert: Bool = false
    
    let workout: Workout
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                DisplayableHero(displayable: workout)

                HStack {
                    Button(.addExercise) {
                        // TODO
                    }
                    .labelStyle(.fixedIconOnly)
                    .buttonStyle(.glass)
                    .buttonBorderShape(.circle)
                    
                    Button(.startSession) {
                        // TODO
                    }
                    .labelStyle(.fixedTitleAndIcon)
                    .buttonStyle(.glassProminent)
                    .tint(.green)
                    
                    Button(.stats) {
                        // TODO
                    }
                    .labelStyle(.fixedIconOnly)
                    .buttonStyle(.glass)
                    .buttonBorderShape(.circle)
                }
                .controlSize(.large)
                
                RowStack(items: workout.entries.sorted()) { entry in
                    WorkoutEntryRow(entry: entry)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .navigationDestination(for: WorkoutEntry.self) { entry in
            WorkoutEntryScreen(entry: entry)
        }
        .toolbar {
            Menu(.more) {
                Section {
                    Button(.addExercise) {
                        
                    }
                    
                    Button(.stats) {
                        
                    }
                }
                Section {
                    Button(.edit) {
                        sheet = .editWorkout(workout: workout)
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
        .alert(.alertWorkoutDeleteTitle, isPresented: $deleteAlert) {
            Button(.delete) {
                delete()
            }
            
            Button(.cancel) {
                
            }
        } message: {
            Text(.alertWorkoutDeleteMessage)
        }
    }
    
    private func delete() {
        modelContext.delete(workout)
        dismiss()
    }
}

private struct WorkoutEntryRow: View {
    let entry: WorkoutEntry
    
    var body: some View {
        NavigationRow(value: entry) {
            DisplayableRow(displayable: entry)
        }
    }
}

#Preview {
    NavigationStack {
        WorkoutScreen(workout: Samples.workouts.first!)
    }
}
