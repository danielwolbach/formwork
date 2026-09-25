//
//  ExerciseForm.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import FormworkKit
import SwiftData
import SwiftUI
import VisionKit
import Vision

struct ExerciseForm: View {
    let exercise: Exercise?

    @Environment(\.dismiss)
    private var dismiss: DismissAction

    @Environment(\.modelContext)
    private var modelContext: ModelContext

    @State
    private var name: String

    @State
    private var type: ExerciseType

    @State
    private var categories: Set<ExerciseCategory>
    
    @State
    private var url: String
    
    @State
    private var notes: String
    
    @State
    private var showScanner: Bool = false

    init(exercise: Exercise? = nil) {
        self._name = State(initialValue: exercise?.name ?? "")
        self._type = State(initialValue: exercise?.type ?? .weight)
        self._categories = State(initialValue: exercise?.categories ?? [])
        self._url = State(initialValue: exercise?.link?.absoluteString ?? "")
        self._notes = State(initialValue: exercise?.notes ?? "")
        self.exercise = exercise
    }

    init(category: ExerciseCategory) {
        self._name = State(initialValue: "")
        self._type = State(initialValue: .weight)
        self._categories = State(initialValue: [category])
        self._url = State(initialValue: "")
        self._notes = State(initialValue: "")
        self.exercise = nil
    }

    var body: some View {
        Form {
            Section(.sectionExerciseNameTitle) {
                TextField(exercise?.name ?? "", text: $name)
            }

            Section(.sectionExerciseTypeTitle) {
                ExerciseTypePicker(type: $type)
            }

            Section(.sectionExerciseCategoriesTitle) {
                ExerciseCategoryPicker(categories: $categories)
            }
            
            Section(.sectionExerciseLinkTitle) {
                HStack {
                    TextField(.fieldExerciseLinkPlaceholder, text: $url)
                        .keyboardType(.URL)
                        .textContentType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    if QRCodeScanner.isSupported {
                        Button(.scan) {
                            showScanner = true
                        }
                        .labelStyle(.iconOnly)
                        .buttonStyle(.borderless)
                    }
                }
            }
            
            Section(.sectionExerciseNotesTitle) {
                TextField(.fieldExerciseNotesPlaceholder, text: $notes, axis: .vertical)
                    .lineLimit(4...)
            }
        }
        .navigationTitle(exercise == nil ? .screenExerciseCreateTitle : .screenExerciseEditTitle)
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(.confirm) {
                    save()
                }
                .disabled(!valid)
            }

            ToolbarItem(placement: .cancellationAction) {
                Button(.cancel) {
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showScanner) {
            NavigationStack {
                QRCodeScanner { scanned in
                    Haptics.notification(.success)
                    url = scanned.absoluteString
                    showScanner = false
                }
                .aspectRatio(1, contentMode: .fit)
                .clipShape(.rect(cornerRadius: 24))
                .padding()
                .navigationTitle(.screenQrCodeScannerTitle)
                .navigationBarTitleDisplayMode(.inline)
                .presentationDetents([.medium])
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(.cancel) {
                            showScanner = false
                        }
                    }
                }
            }
        }
    }

    private var valid: Bool {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let url = url.trimmingCharacters(in: .whitespacesAndNewlines)
        return !name.isEmpty && (url.isEmpty || link != nil)
    }

    private var link: URL? {
        let url = url.trimmingCharacters(in: .whitespacesAndNewlines)
        let link = URL(string: url.contains("://") ? url : "https://\(url)")
        return link?.host() == nil ? nil : link
    }

    private func save() {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let categories = categories.isEmpty ? [.other] : categories
        let notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)

        if let exercise {
            exercise.name = name
            exercise.type = type
            exercise.categories = categories
            exercise.link = link
            exercise.notes = notes
        } else {
            let exercise = Exercise(name: name, type: type, categories: categories, link: link, notes: notes)
            modelContext.insert(exercise)
        }

        dismiss()
    }
}

private struct ExerciseTypePicker: View {
    @Binding
    var type: ExerciseType

    var body: some View {
        LazyVGrid(columns: GridItem.ntile(n: 2)) {
            ForEach(ExerciseType.allCases) { candidate in
                Toggle(isOn: binding(for: candidate)) {
                    VStack {
                        Image(systemName: candidate.pictogram.image)
                            .frame(width: 24, height: 24)

                        Text(candidate.title)
                            .lineLimit(1)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                }
                .toggleStyle(.card(tint: candidate.pictogram.color))
            }
        }
        .buttonBorderShape(.roundedRectangle(radius: 12))
        .sensoryFeedback(.selection, trigger: type)
    }

    private func binding(for candidate: ExerciseType) -> Binding<Bool> {
        Binding(
            get: { type == candidate },
            set: { selected in
                if selected {
                    type = candidate
                }
            }
        )
    }
}

private struct ExerciseCategoryPicker: View {
    @Binding
    var categories: Set<ExerciseCategory>

    var body: some View {
        FlowLayout(spacing: 8) {
            ForEach(ExerciseCategory.allCases, id: \.self) { candidate in
                Toggle(candidate.title, systemImage: candidate.pictogram.image, isOn: binding(for: candidate))
                    .font(.subheadline)
                    .lineLimit(1)
                    .toggleStyle(.card(tint: candidate.pictogram.color))
                    .labelStyle(.fixedTitleAndIcon)
            }
        }
        .buttonBorderShape(.capsule)
        .sensoryFeedback(.selection, trigger: categories)
    }

    private func binding(for candidate: ExerciseCategory) -> Binding<Bool> {
        Binding(
            get: { categories.contains(candidate) },
            set: { selected in
                if selected {
                    categories.insert(candidate)
                } else {
                    categories.remove(candidate)
                }
            }
        )
    }
}

private struct QRCodeScanner: UIViewControllerRepresentable {
    let onScan: (URL) -> Void

    static var isSupported: Bool {
        DataScannerViewController.isSupported
    }

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let controller = DataScannerViewController(
            recognizedDataTypes: [.barcode(symbologies: [.qr])],
            qualityLevel: .balanced,
            recognizesMultipleItems: false,
            isHighFrameRateTrackingEnabled: false,
            isHighlightingEnabled: true
        )
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ controller: DataScannerViewController, context: Context) {
        if !controller.isScanning {
            try? controller.startScanning()
        }
    }

    static func dismantleUIViewController(_ controller: DataScannerViewController, coordinator: Coordinator) {
        controller.stopScanning()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onScan: onScan)
    }

    @MainActor
    final class Coordinator: NSObject, DataScannerViewControllerDelegate {
        private let onScan: (URL) -> Void

        private var scanned: Bool = false

        init(onScan: @escaping (URL) -> Void) {
            self.onScan = onScan
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            guard !scanned else { return }

            for item in addedItems {
                guard
                    case .barcode(let barcode) = item,
                    let payload = barcode.payloadStringValue,
                    let url = URL(string: payload),
                    ["http", "https"].contains(url.scheme?.lowercased()),
                    url.host() != nil
                else { continue }

                scanned = true
                dataScanner.stopScanning()
                onScan(url)
                return
            }
        }
    }
}


#Preview("Create") {
    NavigationStack {
        ExerciseForm()
    }
}

#Preview("Edit") {
    NavigationStack {
        ExerciseForm(exercise: Samples.exercises.first!)
    }
}
