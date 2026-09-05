//
//  SessionMiniPlayer.swift
//  Formwork
//
//  Created by Daniel Wolbach on 05.09.26.
//

import SwiftData
import SwiftUI

struct SessionMiniPlayer: View {
    @Environment(\.presentSession) private var presentSession: PresentSessionAction
    
    let session: Session
    let transitionNamespace: Namespace.ID
    
    var body: some View {
        HStack {
            Button {
                presentSession(session)
            } label: {
                entry
            }
            .buttonStyle(.plain)
            
            controls
        }
        .padding(.horizontal)
        .matchedTransitionSource(id: session.persistentModelID, in: transitionNamespace)
    }
    
    @ViewBuilder
    private var entry: some View {
        if let current = session.current {
            HStack {
                PictogramView(pictogram: current.pictogram, size: 32)
                    .overlay(alignment: .bottomTrailing) {
                        if !current.status.isPending {
                            PictogramBadge(pictogram: current.status.pictogram, size: 12)
                                .offset(x: 2, y: 2)
                        }
                    }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(current.title)
                        .font(.caption)
                    
                    Text(current.subtitle)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            .contentShape(.rect)
        }
    }
    
    private var controls: some View {
        HStack {
            statusAction
            
            Button(.forward, action: advanceToNextEntry)
                .labelStyle(.fixedIconOnly)
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
        }
    }
    
    @ViewBuilder
    private var statusAction: some View {
        switch session.current?.status {
        case .pending:
            Button(.complete, action: completeCurrentEntry)
                .fontWeight(.bold)
                .tint(.green)
                .labelStyle(.fixedIconOnly)
                .buttonStyle(.glassProminent)
                .buttonBorderShape(.circle)
            
        case .completed, .skipped:
            Button(.undo, action: undoCurrentEntry)
                .labelStyle(.fixedIconOnly)
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
            
        case nil:
            EmptyView()
        }
    }
    
    private func completeCurrentEntry() {
        if session.pending.count == 1 {
            presentSession(session)
        }
        
        session.completeAndAdvance()
    }
    
    private func undoCurrentEntry() {
        session.undoStatusChange()
    }
    
    private func advanceToNextEntry() {
        if let next = session.next {
            session.current = next
        } else if let firstEntry = session.firstEntry {
            session.current = firstEntry
        }
    }
}


#Preview {
    @Previewable @Namespace var namespace

    TabView {
        
    }
    .tabViewBottomAccessory {
        SessionMiniPlayer(session: Samples.session, transitionNamespace: namespace)
    }
    .sampleData()
}
