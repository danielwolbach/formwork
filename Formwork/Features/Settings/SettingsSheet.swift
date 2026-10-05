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

struct SettingsSheet: View {
    @Environment(\.dismiss)
    private var dismiss: DismissAction

    @Environment(\.presentPaywall)
    private var presentPaywall: PresentPaywallAction

    @Environment(\.fullVersion)
    private var fullVersion: FullVersion

    @Query(filter: #Predicate<Workout> { $0.isArchived })
    private var archivedWorkouts: [Workout]

    @Query(filter: #Predicate<Exercise> { $0.isArchived })
    private var archivedExercises: [Exercise]

    @AppStorage(StorageKeys.weightSystem, store: AppGroup.defaults)
    private var weightSystem: Units.System = .current

    @AppStorage(StorageKeys.distanceSystem, store: AppGroup.defaults)
    private var distanceSystem: Units.System = .current

    @State
    private var easterEggTaps = 0

    var body: some View {
        ScrollView {
            ContentStack {
                aboutSection

                unitsSection

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
                    LabeledContent {
                        Picker(.fieldWeightUnitTitle, selection: $weightSystem) {
                            ForEach(Units.System.allCases) { system in
                                Text(system.title)
                                    .id(system)
                            }
                        }
                    } label: {
                        Text(.fieldWeightUnitTitle)
                    }

                    Divider()

                    LabeledContent {
                        Picker(.fieldDistanceUnitTitle, selection: $distanceSystem) {
                            ForEach(Units.System.allCases) { system in
                                Text(system.title)
                                    .id(system)
                            }
                        }
                    } label: {
                        Text(.fieldDistanceUnitTitle)
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

    private var archivedCount: Int {
        archivedWorkouts.count + archivedExercises.count
    }
}

#Preview {
    NavigationRoot {
        SettingsSheet()
    }
    .sampleData()
}
