//
//  ExerciseGuide.swift
//  Formwork
//
//  Created by Daniel Wolbach on 25.09.26.
//

import FormworkKit
import Foundation
import SafariServices
import SwiftUI

struct ExerciseGuide: View {
    private struct BrowserPage: Identifiable {
        let url: URL

        var id: URL {
            url
        }
    }

    private let exercise: Exercise

    @Environment(\.openURL)
    private var openURL: OpenURLAction

    @State
    private var browserPage: BrowserPage?

    @State
    private var sheet: Sheet?

    init(_ exercise: Exercise) {
        self.exercise = exercise
    }

    var body: some View {
        VStack(spacing: 8) {
            if let link = exercise.link {
                Button {
                    if ["http", "https"].contains(link.scheme?.lowercased()) {
                        browserPage = BrowserPage(url: link)
                    } else {
                        openURL(link)
                    }
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Label(.fieldLinkTitle, systemImage: "link")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)

                            if let host = link.host().map({ String($0.trimmingPrefix("www.")) }) {
                                Text(host)
                                    .font(.headline)
                                    .lineLimit(1)
                            }
                        }

                        Spacer(minLength: 0)

                        Image(systemName: "arrow.up.right")
                            .foregroundStyle(.tertiary)
                    }
                    .padding()
                    .card()
                }
                .buttonStyle(.plain)
            }

            Button {
                sheet = .editExerciseNotes(exercise)
            } label: {
                VStack(alignment: .leading, spacing: 8) {
                    Label(.fieldNotesTitle, systemImage: "document")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)

                    TextField(.fieldNotesPlaceholder, text: .constant(exercise.notes), axis: .vertical)
                        .lineLimit(4...)
                        .disabled(true)
                }
                .padding()
                .card()
            }
            .buttonStyle(.plain)
        }
        .fullScreenCover(item: $browserPage) { page in
            SafariView(url: page.url) {
                browserPage = nil
            }
            .ignoresSafeArea()
        }
        .sheet(item: $sheet) { sheet in
            NavigationStack {
                sheet
            }
        }
    }
}

private struct SafariView: UIViewControllerRepresentable {
    final class Coordinator: NSObject, SFSafariViewControllerDelegate {
        private let onDone: () -> Void

        init(onDone: @escaping () -> Void) {
            self.onDone = onDone
        }

        func safariViewControllerDidFinish(_: SFSafariViewController) {
            onDone()
        }
    }

    let url: URL

    let onDone: () -> Void

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let controller = SFSafariViewController(url: url)
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_: SFSafariViewController, context _: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onDone: onDone)
    }
}

#Preview {
    ExerciseGuide(Samples.exercises[1])
        .padding()
}
