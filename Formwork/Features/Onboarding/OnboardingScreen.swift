//
//  OnboardingScreen.swift
//  Formwork
//
//  Created by Daniel Wolbach on 20.09.26.
//

import FormworkKit
import FormworkUI
import OSLog
import SwiftData
import SwiftUI

struct OnboardingScreen: View {
    @Environment(\.modelContext)
    private var modelContext: ModelContext

    @Environment(\.dismiss)
    private var dismiss: DismissAction

    @Environment(\.units)
    private var units: Units

    @AppStorage(StorageKeys.onboardingPending)
    private var onboardingPending: Bool = true

    @State
    private var page: Page? = .welcome

    @State
    private var finished: Bool = false

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 0) {
                ForEach(Page.allCases, id: \.self) { page in
                    PageView(page: page)
                        .containerRelativeFrame(.horizontal)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition(id: $page)
        .scrollIndicators(.hidden)
        .sensoryFeedback(.impact(flexibility: .soft), trigger: page)
        .sensoryFeedback(.success, trigger: finished)
        .safeAreaBar(edge: .bottom) {
            controls
        }
        .background {
            LinearGradient(colors: [current.tint.color.opacity(0.25), .clear], startPoint: .top, endPoint: .center)
                .animation(.smooth, value: current)
                .ignoresSafeArea()
        }
    }

    private var controls: some View {
        VStack(spacing: 32) {
            indicator

            primaryAction
                .fontWeight(.semibold)
                .labelStyle(.fixedTitleAndIcon)
                .buttonStyle(.glassProminent)
                .controlSize(.large)
        }
        .padding(.horizontal)
    }

    private var primaryAction: some View {
        Button(.continue) {
            advance()
        }
    }

    private var indicator: some View {
        HStack(spacing: 6) {
            ForEach(Page.allCases, id: \.rawValue) { page in
                Capsule()
                    .fill(.tint)
                    .opacity(page == current ? 1 : 0.2)
                    .frame(width: page == current ? 20 : 6, height: 6)
            }
        }
        .animation(.snappy, value: current)
        .accessibilityHidden(true)
    }

    private var current: Page {
        page ?? .welcome
    }

    private func advance() {
        guard let next = Page(rawValue: current.rawValue + 1) else {
            finish()
            return
        }

        withAnimation(.snappy) {
            page = next
        }
    }

    private func finish() {
        do {
            try StarterCatalog.seed(into: modelContext, units: units)
        } catch {
            Logger.storage.error("Seeding starter catalog failed: \(error, privacy: .public)")
        }

        onboardingPending = false
        dismiss()
    }
}

private enum Page: Int, CaseIterable {
    case welcome, catalog, workouts, sessions, statistics

    var tint: Pictogram.Tint {
        switch self {
        case .welcome: .blue
        case .catalog: .purple
        case .workouts: .indigo
        case .sessions: .green
        case .statistics: .orange
        }
    }

    var title: LocalizedStringResource {
        switch self {
        case .welcome: .onboardingWelcomeTitle
        case .catalog: .onboardingCatalogTitle
        case .workouts: .onboardingWorkoutsTitle
        case .sessions: .onboardingSessionsTitle
        case .statistics: .onboardingStatisticsTitle
        }
    }

    var message: LocalizedStringResource {
        switch self {
        case .welcome: .onboardingWelcomeMessage
        case .catalog: .onboardingCatalogMessage
        case .workouts: .onboardingWorkoutsMessage
        case .sessions: .onboardingSessionsMessage
        case .statistics: .onboardingStatisticsMessage
        }
    }
}

private struct PageView: View {
    let page: Page

    var body: some View {
        ViewThatFits(in: .vertical) {
            content

            ScrollView {
                content
            }
        }
    }

    var content: some View {
        VStack(spacing: 0) {
            preview
                .frame(maxHeight: .infinity)
                .accessibilityHidden(true)

            VStack(spacing: 16) {
                Text(page.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .accessibilityAddTraits(.isHeader)

                Text(page.message)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16)
            .frame(maxHeight: .infinity)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 64)
    }

    @ViewBuilder
    private var preview: some View {
        switch page {
        case .welcome: WelcomePreview()
        case .catalog: CatalogPreview()
        case .workouts: WorkoutPreview()
        case .sessions: SessionPreview()
        case .statistics: StatisticsPreview()
        }
    }
}

private struct WelcomePreview: View {
    var body: some View {
        Image(.imageAppIcon)
            .resizable()
            .frame(width: 192, height: 192)
    }
}

private struct CatalogPreview: View {
    private let exercises: [Exercise] = [
        StarterCatalog.Samples.exercise(of: .weight),
        StarterCatalog.Samples.exercise(of: .bodyweight),
        StarterCatalog.Samples.exercise(of: .duration),
    ]

    var body: some View {
        VStack(spacing: 8) {
            ForEach(Array(exercises.enumerated()), id: \.offset) { position, exercise in
                let depth = CGFloat(position)

                PictogramRow(exercise.pictogram, title: exercise.title, subtitle: exercise.categories.formatted(.exerciseCategories))
                    .scaleEffect(1 - depth * 0.05, anchor: .leading)
                    .offset(x: depth * 12)
            }
        }
        .background(alignment: .trailing) {
            Image(systemName: "magazine")
                .font(.system(size: 160))
                .foregroundStyle(Page.catalog.tint.color.quaternary)
        }
        .clipped()
    }
}

private struct WorkoutPreview: View {
    @Environment(\.units)
    private var units: Units

    var body: some View {
        WorkoutCard(StarterCatalog.Samples.workout(in: units))
            .allowsHitTesting(false)
    }
}

private struct SessionPreview: View {
    private let exercise = StarterCatalog.Samples.exercise(of: .weight)

    @Environment(\.units)
    private var units: Units

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            neighbour(exercise: StarterCatalog.Samples.exercise(of: .duration), badge: .skippedBadge, angle: 16)
            current
            neighbour(exercise: StarterCatalog.Samples.exercise(of: .bodyweight), badge: .pendingBadge, angle: -16)
        }
    }

    private var current: some View {
        VStack(spacing: 16) {
            PictogramView(exercise.pictogram, badge: .completedBadge)
                .frame(width: 144, height: 144)

            VStack {
                Text(exercise.title)
                    .lineLimit(1)
                    .font(.headline)

                Text(StarterCatalog.Samples.weightTarget(in: units).formatted(.exerciseTarget(units: units)))
                    .lineLimit(1)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func neighbour(exercise: Exercise, badge: Pictogram?, angle: Double) -> some View {
        PictogramView(exercise.pictogram, badge: badge)
            .frame(width: 92, height: 92)
            .rotation3DEffect(.degrees(angle), axis: (x: 0, y: 1, z: 0), perspective: 0.6)
            .padding(.top, 32)
    }
}

private struct StatisticsPreview: View {
    @Environment(\.units)
    private var units: Units

    var body: some View {
        TileGrid {
            ReadingCard(StatisticKind.weekStreak.definition, reading: StarterCatalog.Samples.weekStreak)
            ReadingCard(StatisticKind.weeklySessions.definition, reading: StarterCatalog.Samples.weeklySessions)
            ReadingCard(StatisticKind.personalBest.definition, reading: StarterCatalog.Samples.personalBest(in: units))
            ReadingCard(SessionFigureKind.volume.definition, reading: StarterCatalog.Samples.totalVolume(in: units))
        }
    }
}

#Preview {
    NavigationRoot {
        OnboardingScreen()
    }
}
