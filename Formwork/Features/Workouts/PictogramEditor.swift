//
//  PictogramEditor.swift
//  Formwork
//
//  Created by Daniel Wolbach on 18.09.26.
//

import FormworkKit
import FormworkUI
import SwiftUI

struct PictogramEditor: View {
    @Binding
    private var pictogram: Pictogram

    @State
    private var showEditor: Bool = false

    init(_ pictogram: Binding<Pictogram>) {
        self._pictogram = pictogram
    }

    var body: some View {
        PictogramView(pictogram, badge: .editBadge)
            .onTapGesture {
                showEditor = true
            }
            .sheet(isPresented: $showEditor) {
                NavigationStack {
                    PictogramSheet(pictogram: $pictogram)
                }
            }
    }
}

private struct PictogramSheet: View {
    private static let columns: Int = 6

    @Binding
    var pictogram: Pictogram

    @Environment(\.dismiss)
    private var dismiss: DismissAction

    @State
    private var draft: Pictogram

    init(pictogram: Binding<Pictogram>) {
        self._pictogram = pictogram
        self._draft = State(initialValue: pictogram.wrappedValue)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                PictogramView(draft)
                    .frame(width: 128)

                SectionView(.init(localized: .fieldColorTitle)) {
                    GroupBox {
                        PictogramColorPicker(selection: $draft.tint)
                    }
                    .padding(.horizontal)
                }

                SectionView(.init(localized: .fieldImageTitle)) {
                    GroupBox {
                        PictogramImagePicker(selection: $draft.image)
                    }
                    .padding(.horizontal)
                }
            }
        }
        .groupBoxStyle(.card)
        .navigationTitle(.screenPictogramTitle)
        .navigationBarTitleDisplayMode(.inline)
        .sensoryFeedback(.selection, trigger: draft.tint)
        .sensoryFeedback(.selection, trigger: draft.image)
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

private struct PictogramColorPicker: View {
    @Binding
    var selection: Pictogram.Tint

    var body: some View {
        TileGrid(columns: 6, aspectRatio: 1) {
            ForEach(Pictogram.Tint.allCases) { tint in
                PictogramSwatch(
                    fill: AnyShapeStyle(tint.color),
                    ring: AnyShapeStyle(tint.color),
                    selected: tint == selection
                ) {
                    selection = tint
                }
            }
        }
    }
}

private struct PictogramImagePicker: View {
    @Binding
    var selection: String

    var body: some View {
        TileGrid(columns: 6, aspectRatio: 1) {
            ForEach(PictogramEditor.imageOptions, id: \.self) { option in
                PictogramSwatch(
                    fill: AnyShapeStyle(Color.gray.quinary),
                    ring: AnyShapeStyle(Color.gray.secondary),
                    selected: option == selection,
                    image: option
                ) {
                    selection = option
                }
            }
        }
    }
}

private struct PictogramSwatch: View {
    let fill: AnyShapeStyle

    let ring: AnyShapeStyle

    let selected: Bool

    var image: String?

    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Circle()
                .fill(fill)
                .padding(4)
                .overlay {
                    if let image {
                        Image(systemName: image)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                    }
                }
                .overlay {
                    Circle()
                        .stroke(selected ? ring : AnyShapeStyle(Color.clear), lineWidth: 2)
                }
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? [.isSelected] : [])
    }
}

extension PictogramEditor {
    fileprivate static let imageOptions: [String] = [
        Pictogram.workout.image,
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
}

#Preview {
    @Previewable
    @State
    var pictogram: Pictogram = .unknown

    NavigationStack {
        PictogramEditor($pictogram)
            .frame(width: 192)
    }
}
