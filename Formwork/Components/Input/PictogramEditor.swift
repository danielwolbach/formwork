import FormworkKit
import SwiftUI

struct PictogramEditor: View {
    @State private var showEditor: Bool = false
    @Binding var pictogram: Pictogram

    let imageOptions: [String]

    var body: some View {
        PictogramView(pictogram: pictogram, badge: .editBadge)
            .frame(width: 192)
            .onTapGesture {
                showEditor = true
            }
            .sheet(isPresented: $showEditor) {
                NavigationStack {
                    PictogramSheet(pictogram: $pictogram, imageOptions: imageOptions)
                }
            }
    }
}

private struct PictogramSheet: View {
    @Environment(\.dismiss) private var dismiss: DismissAction
    @Binding var pictogram: Pictogram
    @State private var draft: Pictogram

    private static let columns: Int = 6

    let imageOptions: [String]

    init(pictogram: Binding<Pictogram>, imageOptions: [String]) {
        self._pictogram = pictogram
        self._draft = State(initialValue: pictogram.wrappedValue)
        self.imageOptions = imageOptions
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
                ForEach(imageOptions, id: \.self) { option in
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
        PictogramEditor(pictogram: $pictogram, imageOptions: Pictogram.workoutImageOptions)
    }
}
