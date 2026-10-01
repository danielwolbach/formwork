//
//  SettingsScreen.swift
//  Formwork
//
//  Created by Daniel Wolbach on 29.09.26.
//

import FormworkKit
import FormworkUI
import SwiftUI

struct SettingsScreen: View {
    @Environment(\.dismiss)
    private var dismiss: DismissAction

    @AppStorage(StorageKeys.weightSystem, store: AppGroup.defaults)
    private var weightSystem: Units.System = .current

    @AppStorage(StorageKeys.distanceSystem, store: AppGroup.defaults)
    private var distanceSystem: Units.System = .current

    @State
    private var easterEggTaps = 0

    var body: some View {
        ScrollView {
            ContentStack {
                SectionView(.init(localized: .fieldAboutTitle)) {
                    GroupBox {
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
                    }
                }

                SectionView(.init(localized: .fieldUnitsTitle)) {
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
}

#Preview {
    NavigationStack {
        SettingsScreen()
    }
}
