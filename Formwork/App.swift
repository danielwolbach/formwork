//
//  App.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import FormworkKit
import SwiftData
import SwiftUI

@main struct App: SwiftUI.App {
    init() {
        SessionControl.register(SessionController())
    }

    var body: some Scene {
        WindowGroup {
            AppContent()
        }
        .modelContainer(Storage.container)
    }
}

private struct AppContent: View {
    @Query(Session.activeDescriptor) private var activeSessions: [Session]
    @State private var presentedSession: Session? = nil
    @Namespace private var sessionTransition

    private var activeSession: Session? {
        activeSessions.first
    }

    private var activityState: SessionActivityAttributes.ContentState? {
        activeSession.flatMap(SessionActivity.state(for:))
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
        .task(id: activityState) {
            SessionActivity.sync(activeSession)
        }
        .onOpenURL { url in
            guard url == DeepLink.session, let activeSession else {
                return
            }

            presentedSession = activeSession
        }
    }
}

private struct MainTabView: View {
    let activeSession: Session?
    let transitionNamespace: Namespace.ID

    var body: some View {
        TabView {
            Tab(.screenOverviewTitle, systemImage: "text.rectangle.page") {
                NavigationStack {
                    OverviewScreen()
                }
            }

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

            Tab(.screenStatisticsTitle, systemImage: "flame") {
                NavigationStack {
                    StatisticsScreen()
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
