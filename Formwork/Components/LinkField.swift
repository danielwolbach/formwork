//
//  LinkField.swift
//  Formwork
//
//  Created by Daniel Wolbach on 05.10.26.
//

import FormworkUI
import SwiftUI
import Vision
import VisionKit

struct LinkField: View {
    private let placeholder: LocalizedStringResource

    @Binding
    private var text: String

    @State
    private var scanned: URL?

    @State
    private var showScanner: Bool = false

    init(_ placeholder: LocalizedStringResource, text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
    }

    var body: some View {
        HStack {
            TextField(placeholder, text: $text)
                .keyboardType(.URL)
                .textContentType(.URL)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

            if QRCodeScanner.isSupported {
                Button(.scanQRCode) {
                    scanned = nil
                    showScanner = true
                }
                .labelStyle(.fixedIconOnly)
            }
        }
        .sensoryFeedback(.success, trigger: scanned) { _, new in
            new != nil
        }
        .sheet(isPresented: $showScanner) {
            NavigationRoot {
                QRCodeScanner { url in
                    scanned = url
                    text = url.absoluteString
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

#Preview {
    @Previewable @State
    var link = ""

    GroupBox {
        LinkField(.fieldLinkPlaceholder, text: $link)
    }
    .groupBoxStyle(.card)
    .padding()
}
