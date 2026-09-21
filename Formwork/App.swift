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
    @Namespace private var sessionNamespace
    @AppStorage(StorageKeys.onboardingPending) private var onboardingPending: Bool = true
    @State private var presentedSession: Session? = nil

    var body: some View {
        MainTabView(activeSession: activeSession, sessionNamespace: sessionNamespace)
            .environment(\.presentSession, PresentSessionAction(action: presentSession))
            .fullScreenCover(isPresented: onboardingPendingBinding) {
                OnboardingScreen()
            }
            .fullScreenCover(item: presentedSessionBinding) { session in
                NavigationStack {
                    SessionScreen(session: session)
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                Button(.minimize) {
                                    presentedSession = nil
                                }
                            }
                        }
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

    private var activeSession: Session? {
        activeSessions.first
    }

    private var activityState: SessionActivityAttributes.ContentState? {
        activeSession.flatMap(SessionActivityAttributes.ContentState.init(session:))
    }

    private var presentedSessionBinding: Binding<Session?> {
        Binding(get: { presentedSession }, set: { presentedSession = $0 })
    }

    private var onboardingPendingBinding: Binding<Bool> {
        Binding(get: { onboardingPending }, set: { onboardingPending = $0 })
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
