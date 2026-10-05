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
    private let notificationRouter = NotificationRouter()

    @State
    private var fullVersion = FullVersion()

    init() {
        UNUserNotificationCenter.current().delegate = notificationRouter
    }

    var body: some Scene {
        WindowGroup {
            AppContent(notificationRouter: notificationRouter)
                .task {
                    await fullVersion.observe()
                }
                .environment(\.fullVersion, fullVersion)
        }
        .modelContainer(Storage.container)
    }
}

private struct AppContent: View {
    private enum AppTab: Hashable {
        case overview, workouts, catalog, statistics
    }

    let notificationRouter: NotificationRouter

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

    @AppStorage(StorageKeys.dailyReminder)
    private var isDailyReminderEnabled: Bool = true

    @AppStorage(StorageKeys.dailyReminderMinute)
    private var dailyReminderMinute: Int = ReminderOptions.defaultDailyMinute

    @AppStorage(StorageKeys.upcomingReminder)
    private var isUpcomingReminderEnabled: Bool = true

    @State
    private var selectedTab: AppTab = .overview

    @State
    private var presentedSession: Session? = nil

    @Namespace
    private var presentedSessionNamespace: Namespace.ID

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(.screenOverviewTitle, systemImage: "text.rectangle.page", value: .overview) {
                NavigationRoot {
                    OverviewScreen()
                }
            }

            Tab(.screenWorkoutsTitle, systemImage: "clipboard", value: .workouts) {
                NavigationRoot {
                    WorkoutIndexScreen()
                }
            }

            Tab(.screenCatalogTitle, systemImage: "magazine", value: .catalog) {
                NavigationRoot {
                    CatalogScreen()
                }
            }

            Tab(.screenStatisticsTitle, systemImage: "flame", value: .statistics) {
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
        .onChange(of: scenePhase, initial: true) { _, phase in
            switch phase {
            case .active:
                syncReminders()
            case .background:
                try? modelContext.save()
                WidgetCenter.shared.reloadAllTimelines()
            default:
                break
            }
        }
        .onOpenURL { url in
            handleLink(url)
        }
        .onChange(of: notificationRouter.isTapPending, initial: true) { _, isPending in
            guard isPending else {
                return
            }

            notificationRouter.isTapPending = false
            selectedTab = .overview
        }
        // Any saved change can move a planned day, so reminders rebuild after every save.
        .onReceive(NotificationCenter.default.publisher(for: ModelContext.didSave)) { _ in
            syncReminders()
        }
        .onChange(of: reminderOptions) {
            syncReminders()
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

    private var reminderOptions: ReminderOptions {
        ReminderOptions(dailyMinute: isDailyReminderEnabled ? dailyReminderMinute : nil, isUpcomingEnabled: isUpcomingReminderEnabled)
    }

    private var activityState: SessionActivityAttributes.ContentState? {
        guard fullVersion.isUnlocked || !fullVersion.hasCheckedEntitlements else {
            return nil
        }

        return activeSessions.first.flatMap(SessionActivityAttributes.ContentState.init(session:))
    }

    private func syncReminders() {
        Reminders.sync((try? modelContext.fetch(FetchDescriptor<Workout>())) ?? [], options: reminderOptions)
    }

    private func presentSession(session: Session) {
        presentedSession = session
    }

    private func handleLink(_ url: URL) {
        switch url {
        case DeepLink.overview:
            selectedTab = .overview
        case DeepLink.session:
            if let session = activeSessions.first {
                presentedSession = session
            }
        default:
            break
        }
    }
}

#Preview {
    AppContent(notificationRouter: NotificationRouter())
        .sampleData()
}
