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
        .modelContainer(ModelContainerInstance.shared)
    }
}

struct ContentView: View {
    @Query(sort: \Session.started, order: .reverse) private var sessions: [Session]
    @Namespace private var sessionTransitionNamespace
    @State private var presentedSession: Session?
    @State private var sessionActivityCoordinator = SessionActivityCoordinator()

    var body: some View {
        MainTabs(
            presentedSession: $presentedSession,
            activeSession: activeSession,
            sessionTransitionNamespace: sessionTransitionNamespace
        )
        .fullScreenCover(item: $presentedSession) { session in
            NavigationStack {
                SessionPlayerScreen(session: session)
            }
            .navigationTransition(
                .zoom(sourceID: session.persistentModelID, in: sessionTransitionNamespace)
            )
        }
        .task(id: liveActivitySnapshot) {
            await sessionActivityCoordinator.synchronize(with: activeSession)
        }
        .onOpenURL { _ in
            presentedSession = activeSession
        }
    }

    private var activeSession: Session? {
        sessions.activeSession
    }

    private var liveActivitySnapshot: SessionLiveActivitySnapshot? {
        guard let activeSession else {
            return nil
        }

        return SessionLiveActivitySnapshot(
            id: activeSession.activity,
            state: activeSession.liveState
        )
    }
}

private struct SessionLiveActivitySnapshot: Hashable {
    let id: UUID
    let state: SessionActivityAttributes.ContentState
}

private struct MainTabs: View {
    @Binding var presentedSession: Session?

    let activeSession: Session?
    let sessionTransitionNamespace: Namespace.ID

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
                    GlobalStatisticsScreen()
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
