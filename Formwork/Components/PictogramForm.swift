//
//  PictogramForm.swift
//  Formwork
//
//  Created by Daniel Wolbach on 06.09.26.
//

import FormworkKit
import SwiftUI

struct PictogramForm: View {
    @Environment(\.dismiss) private var dismiss: DismissAction
    @Binding var pictogram: Pictogram
    @State private var draft: Pictogram

    static let columns: Int = 6
    static let imageOptions: [String] = [
        "figure.strengthtraining.traditional", "figure", "figure.walk", "figure.run", "figure.barre", "figure.boxing",
        "figure.cooldown", "figure.dance", "figure.flexibility", "figure.gymnastics", "figure.jumprope", "figure.pilates",
        "figure.play", "figure.rolling", "figure.yoga", "figure.cross.training", "figure.strengthtraining.functional", "figure.highintensity.intervaltraining",
        "figure.martial.arts", "figure.indoor.rowing", "figure.step.training", "figure.run.treadmill", "figure.indoor.cycle", "figure.stair.stepper"
    ]
    
    init(pictogram: Binding<Pictogram>) {
        self._pictogram = pictogram
        self._draft = State(initialValue: pictogram.wrappedValue)
    }
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Spacer()
                    PictogramView(pictogram: draft, size: 128)
                    Spacer()
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            }
            Section(.fieldPictogramColorTitle) {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: PictogramForm.columns), spacing: 16) {
                    ForEach(Pictogram.Tint.allCases) { tint in
                        TintButton(tint: tint, isSelected: tint == draft.tint) {
                            draft.tint = tint
                        }
                    }
                }
            }
            
            Section(.fieldPictogramIconTitle) {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: PictogramForm.columns), spacing: 16) {
                    ForEach(PictogramForm.imageOptions, id: \.self) { option in
                        IconButton(icon: option, isSelected: option == draft.icon) {
                            draft.icon = option
                        }
                    }
                }
            }
        }
        .navigationTitle(.screenPictogramTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(.confirm) {
                    pictogram = draft
                    dismiss()
                }
            }

            ToolbarItem(placement: .cancellationAction) {
                Button(.cancel) {
                    dismiss()
                }
            }
        }
    }
}

private struct TintButton: View {
    let tint: Pictogram.Tint
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            fill
                .overlay(ring)
        }
        .buttonStyle(.plain)
    }

    private var fill: some View {
        Circle()
            .fill(tint.color)
            .frame(height: 40)
    }

    private var ring: some View {
        Circle()
            .stroke(ringColor, lineWidth: 2)
            .padding(-4)
    }

    private var ringColor: Color {
        isSelected ? tint.color : .clear
    }
}

private struct IconButton: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            fill
                .overlay(symbol)
                .overlay(ring)
        }
        .buttonStyle(.plain)
    }

    private var fill: some View {
        Circle()
            .fill(.gray.quinary)
            .frame(height: 40)
    }

    private var symbol: some View {
        Image(systemName: icon)
            .font(.subheadline)
            .foregroundStyle(.primary)
    }

    private var ring: some View {
        Circle()
            .stroke(ringColor.secondary, lineWidth: 2)
            .padding(-4)
    }

    private var ringColor: Color {
        isSelected ? .gray : .clear
    }
}

#Preview {
    @Previewable @State var pictogram: Pictogram = .unknown

    NavigationStack {
        PictogramForm(pictogram: $pictogram)
    }
}
