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
    @Query(Session.activeDescriptor) private var activeSessions: [Session]
    @State private var presentedSession: Session? = nil
    @Namespace private var sessionNamespace

    private var activeSession: Session? {
        activeSessions.first
    }

    private var activityState: SessionActivityAttributes.ContentState? {
        activeSession.flatMap(SessionActivityAttributes.ContentState.init(session:))
    }

    var body: some View {
        MainTabView(activeSession: activeSession, sessionNamespace: sessionNamespace)
            .environment(\.presentSession, PresentSessionAction(action: presentSession))
            .fullScreenCover(item: $presentedSession) { session in
                NavigationStack {
                    SessionPlayerScreen(session: session)
                }
                .navigationTransition(.zoom(sourceID: session.persistentModelID, in: sessionNamespace))
            }
            .task(id: activityState) {
                await SessionActivity.sync(activityState)
            }
            .onOpenURL { url in
                guard url == DeepLink.session, let activeSession else {
                    return
                }

                presentedSession = activeSession
            }
    }

    private func presentSession(session: Session) {
        presentedSession = session
    }
}

private struct MainTabView: View {
    let activeSession: Session?
    let sessionNamespace: Namespace.ID

    var body: some View {
        TabView {
            Tab(.screenOverviewTitle, systemImage: "text.rectangle.page") {
                NavigationStack {
                    OverviewScreen()
                }
            }

            Tab(.screenWorkoutsTitle, systemImage: "clipboard") {
                NavigationStack {
                    WorkoutListScreen()
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
                SessionMiniPlayer(session: activeSession, namespace: sessionNamespace)
            }
        }
    }
}

#Preview {
    AppContent()
        .sampleData()
}
