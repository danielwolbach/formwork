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

    private static let columns: Int = 6

    private static let imageOptions: [String] = [
        Pictogram.workout.icon,
        "figure",
        "figure.walk",
        "figure.run",
        "figure.barre",
        "figure.boxing",
        "figure.cooldown",
        "figure.dance",
        "figure.flexibility",
        "figure.gymnastics",
        "figure.jumprope",
        "figure.pilates",
        "figure.play",
        "figure.rolling",
        "figure.yoga",
        "figure.cross.training",
        "figure.strengthtraining.functional",
        "figure.highintensity.intervaltraining",
        "figure.martial.arts",
        "figure.indoor.rowing",
        "figure.step.training",
        "figure.run.treadmill",
        "figure.indoor.cycle",
        "figure.stair.stepper",
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
                TileGrid(columns: PictogramForm.columns) {
                    ForEach(Pictogram.Tint.allCases) { tint in
                        PictogramSwatch(
                            fill: AnyShapeStyle(tint.color),
                            ring: AnyShapeStyle(tint.color),
                            isSelected: tint == draft.tint,
                            label: Text(tint.title)
                        ) {
                            draft.tint = tint
                        }
                    }
                }
            }

            Section(.fieldPictogramIconTitle) {
                TileGrid(columns: PictogramForm.columns) {
                    ForEach(PictogramForm.imageOptions, id: \.self) { option in
                        PictogramSwatch(
                            fill: AnyShapeStyle(Color.gray.quinary),
                            ring: AnyShapeStyle(Color.gray.secondary),
                            isSelected: option == draft.icon,
                            icon: option
                        ) {
                            draft.icon = option
                        }
                    }
                }
            }
        }
        .navigationTitle(.screenPictogramTitle)
        .navigationBarTitleDisplayMode(.inline)
        .sensoryFeedback(.selection, trigger: draft.tint)
        .sensoryFeedback(.selection, trigger: draft.icon)
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

private struct PictogramSwatch: View {
    let fill: AnyShapeStyle
    let ring: AnyShapeStyle
    let isSelected: Bool
    var icon: String?
    var label: Text?
    let action: () -> Void

    var body: some View {
        if let label {
            swatch.accessibilityLabel(label)
        } else {
            swatch
        }
    }

    private var swatch: some View {
        Button(action: action) {
            Circle()
                .fill(fill)
                .frame(height: 40)
                .overlay {
                    if let icon {
                        Image(systemName: icon)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                    }
                }
                .overlay {
                    Circle()
                        .stroke(isSelected ? ring : AnyShapeStyle(Color.clear), lineWidth: 2)
                        .padding(-4)
                }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

#Preview {
    @Previewable @State var pictogram: Pictogram = .workout

    NavigationStack {
        PictogramForm(pictogram: $pictogram)
    }
}
