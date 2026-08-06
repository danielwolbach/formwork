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
    @Query(sort: \Session.started, order: .reverse) private var sessions: [Session]
    @Namespace private var sessionTransitionNamespace
    @State private var presentedSession: Session?

    var body: some View {
        MainTabs(
            activeSession: activeSession,
            sessionTransitionNamespace: sessionTransitionNamespace,
            presentedSession: $presentedSession
        )
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
        sessions.activeSession
    }
}

private struct MainTabs: View {
    let activeSession: Session?
    let sessionTransitionNamespace: Namespace.ID
    @Binding var presentedSession: Session?

    var body: some View {
        TabView {
            Tab(.screenWorkouts, systemImage: "clipboard") {
                NavigationStack {
                    WorkoutListScreen()
                }
            }

            Tab(.screenCatalog, systemImage: "magazine") {
                NavigationStack {
                    DisciplineGridScreen()
                }
            }

            Tab(.screenStats, systemImage: "sparkles") {
                NavigationStack {
                    ContentUnavailableView(.emptyStats, systemImage: "sparkles")
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
        .tabBarMinimizeBehavior(activeSession == nil ? .automatic : .onScrollDown)
    }
}

#Preview {
    ContentView()
        .sampleData()
}
