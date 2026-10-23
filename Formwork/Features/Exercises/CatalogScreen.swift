//
//  CatalogScreen.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import FormworkKit
import FormworkUI
import SwiftData
import SwiftUI

struct CatalogScreen: View {
    private enum Selection: Hashable {
        case category(Exercise.Category)
        case exercise(Exercise.ID)
    }

    private enum Sort: Hashable {
        case category, name, newest

        var descriptor: [SortDescriptor<Exercise>] {
            switch self {
            case .category, .name: [SortDescriptor(\.name)]
            case .newest: [SortDescriptor(\.creationDate, order: .reverse)]
            }
        }
    }

    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass: UserInterfaceSizeClass?

    @Environment(\.modelContext)
    private var context: ModelContext

    @Environment(\.paywall)
    private var paywall: Paywall

    @Environment(\.presentPaywall)
    private var presentPaywall: PresentPaywallAction

    @Query(filter: #Predicate<Exercise> { !$0.isArchived })
    private var exercises: [Exercise]

    @State
    private var sort: Sort = .category

    @State
    private var searchText: String = ""

    @State
    private var searchPresented: Bool = false

    @State
    private var sheet: Sheet?

    @State
    private var selection: Selection?

    @State
    private var detailIdentity = UUID()

    @State
    private var compactColumn: NavigationSplitViewColumn = .sidebar

    var body: some View {
        let matching = matchingExercises

        NavigationSplitView(preferredCompactColumn: $compactColumn) {
            Group {
                if exercises.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        ContentStack {
                            if sort == .category, !searchPresented {
                                categoryGrid
                                    .transition(.blurReplace)
                            } else {
                                exerciseList(matching)
                                    .transition(.blurReplace)
                            }
                        }
                    }
                    .overlay {
                        if !trimmedSearchText.isEmpty, matching.isEmpty {
                            ContentUnavailableView.search(text: trimmedSearchText)
                        }
                    }
                    .contentMargins(.bottom, .sections, for: .scrollContent)
                    .searchable(text: $searchText, isPresented: $searchPresented)
                }
            }
            .navigationTitle(.screenCatalogTitle)
            .toolbar {
                Menu(.more) {
                    Section {
                        Button(.createExercise) {
                            createExercise()
                        }
                    }

                    Section {
                        Menu(.sort) {
                            Picker(.fieldSortTitle, selection: $sort) {
                                Label(.fieldSortCategoryTitle, systemImage: "rectangle.grid.2x2")
                                    .tag(Sort.category)

                                Label(.fieldSortNameTitle, systemImage: "character")
                                    .tag(Sort.name)

                                Label(.fieldSortNewestTitle, systemImage: "clock")
                                    .tag(Sort.newest)
                            }
                        }
                    }
                }
            }
            .animation(.snappy, value: sort)
            .animation(.snappy, value: searchText)
            .animation(.snappy, value: searchPresented)
            .onChange(of: sort) { previous, sort in
                if (previous == .category) != (sort == .category) {
                    select(nil)
                }
            }
        } detail: {
            ZStack {
                NavigationRoot {
                    switch selection {
                    case let .category(category):
                        ExerciseCategoryScreen(category)
                    case let .exercise(id):
                        if let exercise = exercises.first(where: { $0.id == id }) {
                            ExerciseScreen(exercise)
                        } else {
                            noSelection
                        }
                    case nil:
                        noSelection
                    }
                }
                // A fresh stack pops whatever was pushed, even when the same item is tapped again.
                .id(detailIdentity)
            }
        }
        .sheet(item: $sheet) { sheet in
            sheet
        }
    }

    private var noSelection: some View {
        ContentUnavailableView(.emptyExerciseSelectionTitle, systemImage: "magazine")
    }

    private var categoryGrid: some View {
        TileGrid(minimumWidth: 120) {
            ForEach(Exercise.Category.allCases) { category in
                Button {
                    select(.category(category))
                } label: {
                    ExerciseCategoryTile(category: category, exerciseCount: countExercises(in: category), isSelected: isShownSelected(.category(category)))
                }
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label(.emptyExercisesTitle, systemImage: "dumbbell")
        } description: {
            Text(.emptyExercisesMessage)
        } actions: {
            Button(.createExercise) {
                createExercise()
            }
            .labelStyle(.fixedTitleAndIcon)
            .buttonStyle(.cardProminent)
        }
    }

    private var trimmedSearchText: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var matchingExercises: [Exercise] {
        let searchText = trimmedSearchText

        return exercises
            .filter { searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText) }
            .sorted(using: sort.descriptor)
    }

    private func exerciseList(_ exercises: [Exercise]) -> some View {
        LazyVStack(spacing: 0) {
            ForEach(exercises) { exercise in
                Button {
                    select(.exercise(exercise.id))
                } label: {
                    ExerciseRow(exercise, isSelected: isShownSelected(.exercise(exercise.id)))
                }
                .buttonStyle(.plain)
            }
        }
        .swipeActionsContainer()
        .animation(.snappy, value: exercises.count)
        .edgeToEdge()
    }

    /// A collapsed split view keeps the selection after going back, so it is only shown side by side with the detail.
    private func isShownSelected(_ candidate: Selection) -> Bool {
        horizontalSizeClass == .regular && selection == candidate
    }

    private func select(_ selection: Selection?) {
        self.selection = selection
        detailIdentity = UUID()

        // Buttons don't drive a collapsed split view the way list selection does, so it has to be told to show the detail.
        if selection != nil {
            compactColumn = .detail
        }
    }

    private func countExercises(in category: Exercise.Category) -> Int {
        exercises.count { $0.categories.contains(category) }
    }

    private func createExercise() {
        if paywall.canAddExercise(in: context) {
            sheet = .createExercise
        } else {
            presentPaywall()
        }
    }
}

private struct ExerciseCategoryTile: View {
    let category: Exercise.Category

    let exerciseCount: Int

    let isSelected: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Spacer(minLength: 0)

                Text(category.title)
                    .lineLimit(1)
                    .font(.headline)
                    .shadow(color: .black.opacity(0.5), radius: 4)

                Text(exerciseCount.formatted(.exerciseCount))
                    .lineLimit(1)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .minimumScaleFactor(0.5)
                    .shadow(color: .black.opacity(0.5), radius: 4)
            }

            Spacer(minLength: 0)
        }
        .padding()
        .background {
            GeometryReader { geometry in
                let side = min(geometry.size.height, geometry.size.width)

                Image(systemName: category.pictogram.image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: side / 2, height: side / 2, alignment: .topTrailing)
                    .foregroundStyle(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .accessibilityHidden(true)
            }
        }
        .foregroundStyle(.white)
        .glassEffect(.regular.tint(category.pictogram.color), in: .rect(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(category.pictogram.color, lineWidth: 2)
                .opacity(isSelected ? 1 : 0)
                .animation(.snappy(duration: 0.1), value: isSelected)
                .padding(-4)
        }
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

#Preview {
    CatalogScreen()
        .sampleData()
}
