import FormworkKit
import SwiftUI

struct PictogramEditor: View {
    @State private var showEditor: Bool = false
    @Binding var pictogram: Pictogram

    var body: some View {
        PictogramView(pictogram: pictogram, badge: Pictogram(image: "pencil.circle.fill", tint: .gray))
            .frame(width: 192)
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
    @Environment(\.dismiss) private var dismiss: DismissAction
    @Binding var pictogram: Pictogram
    @State private var draft: Pictogram

    private static let columns: Int = 6

    private static let imageOptions: [String] = [
        "figure.strengthtraining.traditional",
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
            previewSection
            tintSection
            imageSection
        }
        .navigationTitle(.screenPictogramEditTitle)
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

    private var previewSection: some View {
        Section {
            HStack {
                Spacer()

                PictogramView(pictogram: draft)
                    .frame(width: 192)

                Spacer()
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())
        }
    }

    private var tintSection: some View {
        Section(.sectionPictogramTintTitle) {
            LazyVGrid(columns: GridItem.ntile(n: Self.columns)) {
                ForEach(Pictogram.Tint.allCases) { tint in
                    PictogramSwatch(
                        fill: AnyShapeStyle(tint.color),
                        ring: AnyShapeStyle(tint.color),
                        selected: tint == draft.tint
                    ) {
                        draft.tint = tint
                    }
                }
            }
        }
    }

    private var imageSection: some View {
        Section(.sectionPictogramImageTitle) {
            LazyVGrid(columns: GridItem.ntile(n: Self.columns)) {
                ForEach(Self.imageOptions, id: \.self) { option in
                    PictogramSwatch(
                        fill: AnyShapeStyle(Color.gray.quinary),
                        ring: AnyShapeStyle(Color.gray.secondary),
                        selected: option == draft.image,
                        image: option
                    ) {
                        draft.image = option
                    }
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
                        .stroke(
                            selected ? ring : AnyShapeStyle(Color.clear),
                            lineWidth: 2
                        )
                }
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? [.isSelected] : [])
    }
}

#Preview {
    @Previewable @State var pictogram: Pictogram = .unknown

    NavigationStack {
        PictogramEditor(pictogram: $pictogram)
    }
}
