//
//  SettingsSheet.swift
//  Formwork
//
//  Created by Daniel Wolbach on 29.09.26.
//

import FormworkKit
import FormworkUI
import SwiftData
import SwiftUI
import UserNotifications

struct SettingsSheet: View {
    @Environment(\.dismiss)
    private var dismiss: DismissAction

    @Environment(\.presentPaywall)
    private var presentPaywall: PresentPaywallAction

    @Environment(\.fullVersion)
    private var fullVersion: FullVersion

    @Environment(\.calendar)
    private var calendar: Calendar

    @Environment(\.openURL)
    private var openURL: OpenURLAction

    @Environment(\.scenePhase)
    private var scenePhase: ScenePhase

    @Query(filter: #Predicate<Workout> { $0.isArchived })
    private var archivedWorkouts: [Workout]

    @Query(filter: #Predicate<Exercise> { $0.isArchived })
    private var archivedExercises: [Exercise]

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
    private var notificationStatus: UNAuthorizationStatus? = nil

    @State
    private var healthStatus: Health.Status? = nil

    @State
    private var easterEggTaps: Int = 0

    var body: some View {
        ScrollView {
            ContentStack {
                aboutSection

                unitsSection

                remindersSection

                healthSection

                archiveSection
            }
        }
        .contentMargins(.bottom, .sections, for: .scrollContent)
        .groupBoxStyle(.card)
        .labeledContentStyle(.row)
        .navigationTitle(.screenSettingsTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(.cancel) {
                    dismiss()
                }
            }
        }
        // Rechecked on return, since notifications get turned on or off in the system's settings.
        .task(id: scenePhase) {
            notificationStatus = await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
            healthStatus = await Health.status()
        }
        .sheet(isPresented: Binding<Bool>(get: { easterEggTaps >= 5 }, set: { _ in easterEggTaps = 0 })) {
            EasterEgg()
                .presentationDragIndicator(.visible)
                .presentationDetents([.medium])
        }
    }

    private var aboutSection: some View {
        SectionView(.fieldAboutTitle) {
            GroupBox {
                VStack(spacing: .groups) {
                    HStack {
                        Image(.imageAppIcon)
                            .resizable()
                            .frame(width: 64, height: 64)
                            .onTapGesture {
                                easterEggTaps += 1
                            }
                            .accessibilityHidden(true)

                        VStack(alignment: .leading) {
                            Text(verbatim: AppMetadata.appName)
                                .font(.headline)
                                .lineLimit(1)

                            if let version = AppMetadata.version {
                                Text(.fieldVersionScheme(version: version))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                        }

                        Spacer(minLength: 0)
                    }

                    if !fullVersion.isUnlocked {
                        Divider()

                        Button {
                            presentPaywall()
                        } label: {
                            Label(.unlockFullVersion)
                                .frame(maxWidth: .infinity)
                        }
                        .fontWeight(.medium)
                        .buttonStyle(.cardProminent)
                    }
                }
            }
        }
    }

    private var unitsSection: some View {
        SectionView(.fieldUnitsTitle) {
            GroupBox {
                VStack(spacing: .groups) {
                    unitRow(.fieldWeightUnitTitle, selection: $weightSystem)

                    Divider()

                    unitRow(.fieldDistanceUnitTitle, selection: $distanceSystem)
                }
            }
        }
    }

    private var remindersSection: some View {
        SectionView(.fieldRemindersTitle) {
            GroupBox {
                VStack(spacing: .groups) {
                    if notificationStatus == .denied {
                        VStack {
                            Text(.fieldRemindersDeniedMessage)
                                .font(.body)
                                .foregroundStyle(.secondary)

                            Button(.openSettings) {
                                if let url = URL(string: UIApplication.openNotificationSettingsURLString) {
                                    openURL(url)
                                }
                            }
                            .labelStyle(.fixedTitleAndIcon)
                            .buttonStyle(.cardProminent)
                        }
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                    } else {
                        Toggle(isOn: $isDailyReminderEnabled) {
                            Text(.fieldDailyReminderTitle)
                        }

                        if isDailyReminderEnabled {
                            Divider()

                            LabeledContent {
                                DateButton(.fieldDailyReminderTimeTitle, date: dailyReminderTime, components: .hourAndMinute)
                            } label: {
                                Text(.fieldDailyReminderTimeTitle)
                            }
                        }

                        Divider()

                        Toggle(isOn: $isUpcomingReminderEnabled) {
                            Text(.fieldUpcomingReminderTitle)

                            Text(.fieldUpcomingReminderSubtitle(minutes: ReminderOptions.lead))
                        }
                    }
                }
            }
            .animation(.snappy, value: isDailyReminderEnabled)
        }
    }

    @ViewBuilder
    private var healthSection: some View {
        if let healthStatus, healthStatus != .unavailable {
            SectionView(.fieldHealthTitle) {
                GroupBox {
                    if healthStatus == .disconnected {
                        VStack {
                            Text(.fieldHealthDisconnectedMessage)
                                .font(.body)
                                .foregroundStyle(.secondary)

                            Button(.connectToHealth) {
                                Task {
                                    try? await Health.connect()
                                    self.healthStatus = await Health.status()
                                }
                            }
                            .labelStyle(.fixedTitleAndIcon)
                            .buttonStyle(.cardProminent)
                        }
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                    } else {
                        LabeledContent {
                            if healthStatus == .connected {
                                Label(.fieldConnectedTitle, systemImage: "checkmark")
                                    .labelStyle(.chip(tint: .green))
                            } else {
                                Label(.fieldDeniedTitle, systemImage: "xmark")
                                    .labelStyle(.chip(tint: .red))
                            }
                        } label: {
                            Text(.fieldStatusTitle)

                            Text(.fieldHealthStatusMessage)
                        }
                    }
                }
            }
        }
    }

    private var archiveSection: some View {
        SectionView(.fieldArchiveTitle) {
            GroupBox {
                NavigationLink(value: Route.archive) {
                    LabeledContent {
                        HStack {
                            Text(archivedCount, format: .number)
                                .foregroundStyle(.secondary)

                            Image(systemName: "chevron.forward")
                                .foregroundStyle(.tertiary)
                                .accessibilityHidden(true)
                        }
                    } label: {
                        Text(.fieldArchivedItemsTitle)
                    }
                    .contentShape(.rect)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var dailyReminderTime: Binding<Date> {
        Binding(
            get: {
                calendar.date(bySettingHour: dailyReminderMinute / 60, minute: dailyReminderMinute % 60, second: 0, of: .now) ?? .now
            },
            set: { newValue in
                let time = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                dailyReminderMinute = (time.hour ?? 0) * 60 + (time.minute ?? 0)
            }
        )
    }

    private var archivedCount: Int {
        archivedWorkouts.count + archivedExercises.count
    }

    private func unitRow(_ title: LocalizedStringResource, selection: Binding<Units.System>) -> some View {
        LabeledContent {
            Menu {
                Picker(title, selection: selection) {
                    ForEach(Units.System.allCases) { system in
                        Text(system.title)
                            .tag(system)
                    }
                }
            } label: {
                Text(selection.wrappedValue.title)
            }
            .buttonStyle(.cardProminent)
            .accessibilityLabel(Text(title))
            .accessibilityValue(Text(selection.wrappedValue.title))
        } label: {
            Text(title)
        }
    }
}

#Preview {
    NavigationRoot {
        SettingsSheet()
    }
    .sampleData()
}
