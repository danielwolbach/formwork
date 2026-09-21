//
//  OnboardingScreen.swift
//  Formwork
//
//  Created by Daniel Wolbach on 20.09.26.
//

import FormworkKit
import SwiftData
import SwiftUI

struct OnboardingScreen: View {
    @Environment(\.modelContext) private var modelContext: ModelContext
    @Environment(\.dismiss) private var dismiss: DismissAction
    @AppStorage(StorageKeys.onboardingPending) private var onboardingPending: Bool = true
    @State private var page: Int? = Page.welcome.rawValue

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 0) {
                ForEach(Page.allCases, id: \.rawValue) { page in
                    PageView(page: page)
                        .containerRelativeFrame(.horizontal)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition(id: $page)
        .scrollIndicators(.hidden)
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
        Button(.coninue) {
            navigate(to: current.rawValue + 1)
        }
    }

    private var current: Page {
        page.flatMap(Page.init(rawValue:)) ?? .welcome
    }

    private var indicator: some View {
        HStack(spacing: 6) {
            ForEach(Page.allCases, id: \.rawValue) { page in
                Capsule().fill(.tint).opacity(page == current ? 1 : 0.2).frame(width: page == current ? 20 : 6, height: 6)
            }
        }
        .animation(.snappy, value: current)
        .accessibilityHidden(true)
    }

    private func navigate(to rawValue: Int) {
        guard let next = Page(rawValue: rawValue) else {
            finish()
            return
        }

        Haptics.impact(.soft)

        withAnimation(.snappy) {
            page = next.rawValue
        }
    }

    private func finish() {
        do {
            try StarterCatalog.seed(into: modelContext)
        } catch {
            // TODO: Log error
        }

        Haptics.notification(.success)
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
        VStack(spacing: 64) {
            Spacer(minLength: 0)

            preview
                .frame(height: 256)
                .frame(maxWidth: .infinity)

            VStack(spacing: 16) {
                Text(page.title)
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))

                Text(page.message)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            .multilineTextAlignment(.center)
            .frame(height: 128)
            .padding(.horizontal)

            Spacer(minLength: 0)
        }
        .padding(.horizontal)
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
        PictogramView(pictogram: .workout)
            .frame(width: 192, height: 192)
    }
}

private struct CatalogPreview: View {
    private let exercises: [Exercise] = [
        StarterCatalog.detachedExerciseSample(of: .weight),
        StarterCatalog.detachedExerciseSample(of: .bodyweight),
        StarterCatalog.detachedExerciseSample(of: .duration),
    ]

    var body: some View {
        VStack(spacing: 8) {
            ForEach(Array(exercises.enumerated()), id: \.offset) { position, exercise in
                let depth = CGFloat(position)

                PictogramRow(exercise)
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
    var body: some View {
        WorkoutCard(workout: StarterCatalog.detatchedWorkoutSample())
    }
}

private struct SessionPreview: View {
    private let exercise = StarterCatalog.detachedExerciseSample(of: .weight)
    private let target = Samples.weightTarget

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            neighbour(exercise: StarterCatalog.detachedExerciseSample(of: .duration), badge: .skippedBadge, angle: 16)
            current
            neighbour(exercise: StarterCatalog.detachedExerciseSample(of: .bodyweight), badge: .pendingBadge, angle: -16)
        }
    }

    private var current: some View {
        VStack(spacing: 16) {
            PictogramView(pictogram: exercise.pictogram, badge: .completedBadge)
                .frame(width: 144, height: 144)

            VStack {
                Text(exercise.title)
                    .lineLimit(1)
                    .font(.headline)

                if let subtitle = target.subtitle {
                    Text(subtitle)
                        .lineLimit(1)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func neighbour(exercise: Exercise, badge: Pictogram?, angle: Double) -> some View {
        PictogramView(pictogram: exercise.pictogram, badge: badge)
            .frame(width: 92, height: 92)
            .rotation3DEffect(.degrees(angle), axis: (x: 0, y: 1, z: 0), perspective: 0.6)
            .padding(.top, 32)
    }
}

private struct StatisticsPreview: View {
    var body: some View {
        LazyVGrid(columns: GridItem.ntile(n: 2, spacing: 8), spacing: 8) {
            ForEach(Array(Samples.statistics.enumerated()), id: \.offset) { _, statistic in
                StatisticCard(statistic)
            }
        }
    }
}

#Preview {
    OnboardingScreen()
}
