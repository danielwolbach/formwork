//
//  App.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import FormworkKit
import FormworkUI
import SwiftData
import SwiftUI
import WidgetKit

@main
struct App: SwiftUI.App {
    @State
    private var fullVersion = FullVersion()

    var body: some Scene {
        WindowGroup {
            AppContent()
                .task {
                    await fullVersion.observe()
                }
                .environment(\.fullVersion, fullVersion)
        }
        .modelContainer(Storage.container)
    }
}

private struct AppContent: View {
    @Environment(\.modelContext)
    private var modelContext: ModelContext

    @Environment(\.scenePhase)
    private var scenePhase: ScenePhase

    @Environment(\.fullVersion)
    private var fullVersion: FullVersion

    @Query(Session.activeDescriptor)
    private var activeSessions: [Session]

    @Query(filter: #Predicate<Workout> { !$0.isArchived })
    private var workouts: [Workout]

    @Query(filter: #Predicate<Exercise> { !$0.isArchived })
    private var exercises: [Exercise]

    @AppStorage(StorageKeys.onboardingPending)
    private var onboardingPending: Bool = true

    @AppStorage(StorageKeys.weightSystem, store: AppGroup.defaults)
    private var weightSystem: Units.System = .current

    @AppStorage(StorageKeys.distanceSystem, store: AppGroup.defaults)
    private var distanceSystem: Units.System = .current

    @State
    private var presentedSession: Session? = nil

    @Namespace
    private var presentedSessionNamespace: Namespace.ID

    var body: some View {
        TabView {
            Tab(.screenOverviewTitle, systemImage: "text.rectangle.page") {
                NavigationRoot {
                    OverviewScreen()
                }
            }

            Tab(.screenWorkoutsTitle, systemImage: "clipboard") {
                NavigationRoot {
                    WorkoutIndexScreen()
                }
            }

            Tab(.screenCatalogTitle, systemImage: "magazine") {
                NavigationRoot {
                    CatalogScreen()
                }
            }

            Tab(.screenStatisticsTitle, systemImage: "flame") {
                NavigationRoot {
                    StatisticsScreen()
                }
            }
        }
        .paywallPresenter()
        // Closes by itself once archiving or unlocking makes the condition false.
        .fullScreenCover(isPresented: Binding<Bool>(get: { needsDowngrade }, set: { _ in })) {
            NavigationRoot {
                DowngradeScreen()
            }
            .paywallPresenter()
        }
        .fullScreenCover(isPresented: $onboardingPending) {
            NavigationRoot {
                OnboardingScreen()
            }
        }
        .fullScreenCover(item: $presentedSession) { session in
            NavigationRoot {
                SessionPlayerScreen(session)
            }
            .navigationTransition(.zoom(sourceID: session.persistentModelID, in: presentedSessionNamespace))
        }
        .tabBarMinimizeBehavior(activeSessions.isEmpty ? .automatic : .onScrollDown)
        .tabViewBottomAccessory(isEnabled: !activeSessions.isEmpty) {
            if let session = activeSessions.first {
                // Keyed by session, so replacing it rebuilds the navigator instead of keeping the deleted one.
                SessionMiniPlayer(session, namespace: presentedSessionNamespace)
                    .id(session.persistentModelID)
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
        .onChange(of: scenePhase) { _, phase in
            if phase == .background {
                try? modelContext.save()
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
        // Outermost, so the covers and the bottom accessory read the environment too.
        .environment(\.presentSession, PresentSessionAction(action: presentSession))
        .environment(\.units, Units(weight: weightSystem, distance: distanceSystem))
    }

    private var needsDowngrade: Bool {
        guard fullVersion.hasCheckedEntitlements, !fullVersion.isUnlocked, !onboardingPending, presentedSession == nil else {
            return false
        }

        return workouts.count > FullVersion.workoutLimit || exercises.count > FullVersion.exerciseLimit
    }

    private var activityState: SessionActivityAttributes.ContentState? {
        guard fullVersion.isUnlocked || !fullVersion.hasCheckedEntitlements else {
            return nil
        }

        return activeSessions.first.flatMap(SessionActivityAttributes.ContentState.init(session:))
    }

    private func presentSession(session: Session) {
        presentedSession = session
    }
}

#Preview {
    AppContent()
        .sampleData()
}
