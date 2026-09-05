//
//  App.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import SwiftData
import SwiftUI

@main struct App: SwiftUI.App {
    private static let container: ModelContainer = {
        if ProcessInfo.processInfo.arguments.contains("--sample-data") {
            return Samples.container
        } else {
            let schema = Schema([Exercise.self, Workout.self, WorkoutEntry.self, Session.self, SessionEntry.self])
            return try! ModelContainer(for: schema, configurations: [ModelConfiguration(schema: schema)])
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            AppContent()
        }
        .modelContainer(Self.container)
    }
}

private struct AppContent: View {
    @Query(Session.activeDescriptor) private var activeSessions: [Session]
    @State private var presentedSession: Session? = nil
    @Namespace private var sessionTransition

    private var activeSession: Session? {
        activeSessions.first
    }

    var body: some View {
        MainTabView(
            activeSession: activeSession,
            transitionNamespace: sessionTransition
        )
        .environment(\.presentSession, PresentSessionAction { session in
            presentedSession = session
        })
        .fullScreenCover(item: $presentedSession) { session in
            NavigationStack {
                SessionPlayerScreen(session: session)
            }
            .navigationTransition(.zoom(sourceID: session.persistentModelID, in: sessionTransition))
        }
    }
}

private struct MainTabView: View {
    let activeSession: Session?
    let transitionNamespace: Namespace.ID

    var body: some View {
        TabView {
            Tab(.screenWorkoutsTitle, systemImage: "clipboard") {
                NavigationStack {
                    WorkoutsScreen()
                }
            }

            Tab(.screenCatalogTitle, systemImage: "magazine") {
                NavigationStack {
                    CatalogScreen()
                }
            }
        }
        .tabBarMinimizeBehavior(activeSession == nil ? .automatic : .onScrollDown)
        .tabViewBottomAccessory(isEnabled: activeSession != nil) {
            if let activeSession {
                SessionMiniPlayer(session: activeSession, transitionNamespace: transitionNamespace)
            }
        }
    }
}
#Preview {
    AppContent()
        .sampleData()
}
