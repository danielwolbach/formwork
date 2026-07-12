//
//  App.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import SwiftData
import SwiftUI

@main
struct GymTrackApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Exercise.self, Workout.self, WorkoutEntry.self, Session.self, SessionEntry.self])
    }
}

struct ContentView: View {
    @Query private var sessions: [Session]
    @Namespace private var sessionTransitionNamespace
    @State private var presentedSession: Session?

    var body: some View {
        MainTabs(
            activeSession: activeSession,
            sessionTransitionNamespace: sessionTransitionNamespace,
            presentedSession: $presentedSession
        )
        .equatable()
        .fullScreenCover(item: $presentedSession) { session in
            NavigationStack {
                SessionPlayerScreen(session: session)
            }
            .navigationTransition(
                .zoom(sourceID: session.persistentModelID, in: sessionTransitionNamespace)
            )
        }
    }

    private var activeSession: Session? {
        sessions.first { !$0.entries.isEmpty }
    }
}

private struct MainTabs: View, Equatable {
    let activeSession: Session?
    let sessionTransitionNamespace: Namespace.ID
    @Binding var presentedSession: Session?

    static func == (lhs: Self, rhs: Self) -> Bool {
        // Keep the UIKit-backed accessory mounted while the active session mutates.
        lhs.activeSession?.persistentModelID == rhs.activeSession?.persistentModelID
    }

    var body: some View {
        TabView {
            Tab("Workouts", systemImage: "clipboard") {
                NavigationStack {
                    WorkoutListScreen()
                }
            }

            Tab("Catalog", systemImage: "magazine") {
                NavigationStack {
                    DisciplineGridScreen()
                }
            }

            Tab("Stats", systemImage: "sparkles") {
                NavigationStack {
                    ContentUnavailableView("Stats", systemImage: "sparkles")
                }
            }
        }
        .environment(\.presentSession, PresentSessionAction { session in
            presentedSession = session
        })
        .tabViewBottomAccessory(isEnabled: activeSession != nil) {
            if let activeSession {
                SessionMiniPlayer(
                    session: activeSession,
                    transitionNamespace: sessionTransitionNamespace
                )
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
    }
}

#Preview {
    ContentView()
        .sampleData()
}
