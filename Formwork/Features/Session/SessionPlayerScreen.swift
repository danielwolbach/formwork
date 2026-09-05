//
//  SessionPlayerScreen.swift
//  Formwork
//
//  Created by Daniel Wolbach on 05.09.26.
//

import SwiftUI

struct SessionPlayerScreen: View {
    @Environment(\.dismiss) private var dismiss: DismissAction
    @State private var finishAlert: Bool = false
    @State private var cancelAlert: Bool = false
    
    let session: Session
    
    var body: some View {
        currentView
            .safeAreaBar(edge: .bottom, spacing: 0) {
                controls
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    SessionTimer(session: session)
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button(.minimize) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: . topBarTrailing) {
                    Menu(.more) {
                        Section {
                            Button(.finishSession) {
                                finishAlert = true
                            }
                        }
                        
                        Section {
                            Button(.cancelSession) {
                                cancelAlert = true
                            }
                        }
                    }
                }
            }
            .alert(.alertSessionFinishTitle, isPresented: $finishAlert) {
                Button(.finishSession) {
                    finish()
                }
                
                Button(.cancel) {
                    
                }
            } message: {
                Text(.alertSessionFinishMessage)
            }
            .alert(.alertSessionCancelTitle, isPresented: $cancelAlert) {
                Button(.cancelSession) {
                    cancel()
                }
                
                Button(.cancel) {
                    
                }
            } message: {
                Text(.alertSessionCancelMessage)
            }
    }
    
    @ViewBuilder
    private var currentView: some View {
        if let current = session.current {
            @Bindable var current = current
            
            VStack(spacing: 32) {
                DisplayableHero(displayable: current.exercise)
                
                ExerciseTargetView(target: $current.target)
                
                Spacer()
            }
        }
    }
    
    private var controls: some View {
        VStack(spacing: 16) {
            HStack {
                Button(.backward) {
                    session.moveToPrevious()
                }
                .disabled(session.previous == nil)
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
                .labelStyle(.fixedIconOnly)
                
                primaryAction
                    .buttonStyle(.glassProminent)
                    .labelStyle(.fixedTitleAndIcon)
                
                Button(.forward) {
                    session.moveToNext()
                }
                .disabled(session.next == nil)
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
                .labelStyle(.fixedIconOnly)
            }
            .controlSize(.large)
            
            secondaryAction
                .buttonStyle(.borderless)
                .labelStyle(.fixedTitleAndIcon)
                .foregroundStyle(.secondary)
                .controlSize(.small)
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var primaryAction: some View {
        if session.isComplete {
            Button(.finishSession) {
                finishAlert = true
            }
            .fontWeight(.semibold)
        } else if let status = session.current?.status {
            if status.isPending {
                Button(.complete) {
                    session.completeAndAdvance()
                }
                .fontWeight(.semibold)
                .tint(.green)
            } else {
                Button(status.title, systemImage: status.pictogram.icon) {
                    // Already resolved and always disabled.
                }
                .fontWeight(.semibold)
                .disabled(true)
            }
        }
    }
    
    @ViewBuilder
    private var secondaryAction: some View {
        if let status = session.current?.status {
            if status.isPending {
                Button(.skipExercise) {
                    session.skipAndAdvance()
                }
            } else {
                Button(.undo) {
                    session.undoStatusChange()
                }
            }
        }
    }
    
    private func finish() {
        do {
            try session.finish()
            dismiss()
        } catch {
            // TODO: Log error
        }
    }
    
    private func cancel() {
        do {
            try session.cancel()
            dismiss()
        } catch {
            // TODO: Log error
        }
    }
}

#Preview {
    NavigationStack {
        SessionPlayerScreen(session: Samples.session)
    }
    .sampleData()
}
