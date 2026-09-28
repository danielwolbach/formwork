//
//  App.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import FormworkKit
import SwiftData
import SwiftUI

@main
struct App: SwiftUI.App {
    var body: some Scene {
        WindowGroup {
            AppContent()
        }
        .modelContainer(Storage.container)
    }
}

private struct AppContent: View {
    @Query(Session.activeDescriptor)
    private var activeSessions: [Session]

    @AppStorage(StorageKeys.onboardingPending)
    private var onboardingPending: Bool = true

    @State
    private var presentedSession: Session? = nil

    @Namespace
    private var presentedSessionNamespace: Namespace.ID

    var body: some View {
        TabView {
            Tab(.placeholder, systemImage: "text.rectangle.page") {
                NavigationStack {
                    OverviewScreen()
                }
            }

            Tab(.screenWorkoutsTitle, systemImage: "clipboard") {
                NavigationStack {
                    WorkoutIndexScreen()
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
        .environment(\.presentSession, PresentSessionAction(action: presentSession))
        .fullScreenCover(isPresented: $onboardingPending) {
            OnboardingScreen()
        }
        .fullScreenCover(item: $presentedSession) { session in
            NavigationStack {
                SessionPlayerScreen(session)
            }
            .navigationTransition(.zoom(sourceID: session.persistentModelID, in: presentedSessionNamespace))
        }
        .tabBarMinimizeBehavior(activeSessions.isEmpty ? .automatic : .onScrollDown)
        .tabViewBottomAccessory(isEnabled: !activeSessions.isEmpty) {
            if let session = activeSessions.first {
                SessionMiniPlayer(session, namespace: presentedSessionNamespace)
            }
        }
        .task(id: activityState) {
            await SessionActivity.sync(activityState)
        }
        .onOpenURL { url in
            guard url == DeepLink.session, let session = activeSessions.first else {
                return
            }

            presentedSession = session
        }
    }

    private var activityState: SessionActivityAttributes.ContentState? {
        activeSessions.first.flatMap(SessionActivityAttributes.ContentState.init(session:))
    }

    private func presentSession(session: Session) {
        presentedSession = session
    }
}

#Preview {
    AppContent()
        .sampleData()
}
