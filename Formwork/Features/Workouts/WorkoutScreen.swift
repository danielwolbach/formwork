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
    @Environment(\.presentSession) private var presentSession: PresentSessionAction
    @Query(Session.activeDescriptor) private var activeSessions: [Session]
    @State private var sheet: Sheet? = nil
    @State private var deleteAlert: Bool = false
    @State private var sessionActiveAlert: Bool = false
    
    let workout: Workout
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                DisplayableHero(displayable: workout)

                HStack {
                    Button(.addExercise) {
                        sheet = .addWorkoutExercise(workout: workout)
                    }
                    .labelStyle(.fixedIconOnly)
                    .buttonStyle(.glass)
                    .buttonBorderShape(.circle)
                    
                    Button(.startSession) {
                        startSession()
                    }
                    .disabled(workout.entries.isEmpty)
                    .labelStyle(.fixedTitleAndIcon)
                    .buttonStyle(.glassProminent)
                    .tint(.green)
                    
                    Button(.statistics) {
                        sheet = .workoutStats(workout: workout)
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
                        sheet = .addWorkoutExercise(workout: workout)
                    }
                    
                    Button(.statistics) {
                        sheet = .workoutStats(workout: workout)
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
        .alert(.alertSessionReplaceTitle, isPresented: $sessionActiveAlert) {
            Button(.replaceSession) {
                replaceSession()
            }
            
            if let activeSession {
                Button(.resumeSession) {
                    presentSession(activeSession)
                }
            }
            
            Button(.cancel) {
                
            }
        } message: {
            Text(.alertSessionReplaceMessage)
        }
    }
    
    private func delete() {
        modelContext.delete(workout)
        dismiss()
    }
    
    private var activeSession: Session? {
        activeSessions.first
    }
    
    private func startSession() {
        guard activeSession == nil else {
            sessionActiveAlert = true
            return
        }
        
        replaceSession()
    }
    
    private func replaceSession() {
        do {
            let session = try Session.start(workout, in: modelContext)

            DispatchQueue.main.async {
                presentSession(session)
            }
        } catch {
            // TODO: Log error
        }
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
    .sampleData()
}
