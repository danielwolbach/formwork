//
//  ExerciseForm.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import FormworkKit
import FormworkUI
import SwiftData
import SwiftUI
import Vision
import VisionKit

struct ExerciseForm: View {
    private let exercise: Exercise?

    @Environment(\.modelContext)
    private var context: ModelContext

    @Environment(\.dismiss)
    private var dismiss: DismissAction

    @State
    private var name: String = ""

    @State
    private var kind: Exercise.Kind = .weight

    @State
    private var categories: Set<Exercise.Category> = []

    @State
    private var link: String = ""

    @State
    private var notes: String = ""

    @State
    private var showScanner: Bool = false

    init(_ exercise: Exercise? = nil) {
        self._name = .init(initialValue: exercise?.name ?? "")
        self._kind = .init(initialValue: exercise?.kind ?? .weight)
        self._categories = .init(initialValue: exercise?.categories ?? [])
        self._link = .init(initialValue: exercise?.link?.absoluteString ?? "")
        self._notes = .init(initialValue: exercise?.notes ?? "")
        self.exercise = exercise
    }

    init(categories: Set<Exercise.Category>) {
        self._name = .init(initialValue: "")
        self._kind = .init(initialValue: .weight)
        self._categories = .init(initialValue: categories)
        self._link = .init(initialValue: "")
        self._notes = .init(initialValue: "")
        self.exercise = nil
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                SectionView(.init(localized: .fieldNameTitle)) {
                    GroupBox {
                        TextField(.fieldNamePlaceholder, text: $name)
                    }
                    .padding(.horizontal)
                }

                SectionView(.init(localized: .fieldKindTitle)) {
                    GroupBox {
                        ExerciseKindPicker(kind: $kind)
                    }
                    .padding(.horizontal)
                }

                SectionView(.init(localized: .fieldCategoryTitle)) {
                    GroupBox {
                        ExerciseCategoryPicker(categories: $categories)
                    }
                    .padding(.horizontal)
                }

                SectionView(.init(localized: .fieldLinkTitle)) {
                    GroupBox {
                        HStack {
                            TextField(.fieldLinkPlaceholder, text: $link)
                                .keyboardType(.URL)
                                .textContentType(.URL)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()

                            if QRCodeScanner.isSupported {
                                Button(.scanQRCode) {
                                    showScanner = true
                                }
                                .labelStyle(.fixedIconOnly)
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                SectionView(.init(localized: .fieldNotesTitle)) {
                    NavigationLink {
                        ExerciseNotesScreen(notes: $notes)
                    } label: {
                        GroupBox {
                            TextField(.fieldNotesPlaceholder, text: .constant(notes), axis: .vertical)
                                .lineLimit(4...)
                                .disabled(true)
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal)
                }
            }
        }
        .groupBoxStyle(.card)
        .navigationTitle(exercise == nil ? .screenCreateExerciseTitle : .screenEditExerciseTile)
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.immediately)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(.cancel) {
                    dismiss()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button(.confirm) {
                    commit()
                }
                .disabled(!valid)
            }
        }
        .sheet(isPresented: $showScanner) {
            NavigationStack {
                QRCodeScanner { scanned in
                    Haptics.notification(.success)
                    link = scanned.absoluteString
                    showScanner = false
                }
                .aspectRatio(1, contentMode: .fit)
                .clipShape(.rect(cornerRadius: 24))
                .padding()
                .navigationTitle(.screenScanQRCodeTitle)
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
        let link = link.trimmingCharacters(in: .whitespacesAndNewlines)
        return !name.isEmpty && (link.isEmpty || url != nil)
    }

    private var url: URL? {
        let link = link.trimmingCharacters(in: .whitespacesAndNewlines)
        let url = URL(string: link.contains("://") ? link : "https://\(link)")
        return url?.host() == nil ? nil : url
    }

    private func commit() {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let categories = categories.isEmpty ? [.other] : categories
        let notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)

        if let exercise {
            exercise.name = name
            exercise.kind = kind
            exercise.categories = categories
            exercise.link = url
            exercise.notes = notes
        } else {
            let exercise = Exercise(name: name, kind: kind, categories: categories, link: url, notes: notes)
            context.insert(exercise)
        }

        dismiss()
    }
}

private struct ExerciseKindPicker: View {
    @Binding
    private var kind: Exercise.Kind

    init(kind: Binding<Exercise.Kind>) {
        self._kind = kind
    }

    var body: some View {
        TileGrid {
            ForEach(Exercise.Kind.allCases) { candidate in
                Button {
                    kind = candidate
                } label: {
                    VStack {
                        Image(systemName: candidate.pictogram.image)
                            .frame(width: 24, height: 24)
                            .fontWeight(.medium)

                        Text(candidate.title)
                            .lineLimit(1)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(CardButtonStyle(style: kind == candidate ? .selected : .bordered))
                .tint(candidate.pictogram.color)
            }
        }
        .buttonBorderShape(.roundedRectangle(radius: 8))
        .sensoryFeedback(.selection, trigger: kind)
    }
}

private struct ExerciseCategoryPicker: View {
    @Binding
    private var categories: Set<Exercise.Category>

    init(categories: Binding<Set<Exercise.Category>>) {
        self._categories = categories
    }

    var body: some View {
        FlowLayout(spacing: 8) {
            ForEach(Exercise.Category.allCases) { candidate in
                Button(candidate.title, systemImage: candidate.pictogram.image) {
                    categories.formSymmetricDifference([candidate])
                }
                .font(.subheadline)
                .lineLimit(1)
                .buttonStyle(CardButtonStyle(style: categories.contains(candidate) ? .selected : .bordered))
                .tint(candidate.pictogram.color)
                .labelStyle(.fixedTitleAndIcon)
            }
        }
        .buttonBorderShape(.capsule)
        .sensoryFeedback(.selection, trigger: categories)
    }
}

private struct QRCodeScanner: UIViewControllerRepresentable {
    @MainActor
    final class Coordinator: NSObject, DataScannerViewControllerDelegate {
        private let onScan: (URL) -> Void

        private var scanned: Bool = false

        init(onScan: @escaping (URL) -> Void) {
            self.onScan = onScan
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems _: [RecognizedItem]) {
            guard !scanned else {
                return
            }

            for item in addedItems {
                guard
                    case let .barcode(barcode) = item,
                    let payload = barcode.payloadStringValue,
                    let url = URL(string: payload),
                    ["http", "https"].contains(url.scheme?.lowercased()),
                    url.host() != nil
                else {
                    continue
                }

                scanned = true
                dataScanner.stopScanning()
                onScan(url)
                return
            }
        }
    }

    let onScan: (URL) -> Void

    static var isSupported: Bool {
        DataScannerViewController.isSupported
    }

    static func dismantleUIViewController(_ controller: DataScannerViewController, coordinator _: Coordinator) {
        controller.stopScanning()
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

    func updateUIViewController(_ controller: DataScannerViewController, context _: Context) {
        if !controller.isScanning {
            try? controller.startScanning()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onScan: onScan)
    }
}

#Preview("Create") {
    NavigationStack {
        ExerciseForm()
    }
}

#Preview("Edit") {
    NavigationStack {
        ExerciseForm(Samples.exercises.first!)
    }
}
