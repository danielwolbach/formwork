//
//  ExerciseGuide.swift
//  Formwork
//
//  Created by Daniel Wolbach on 25.09.26.
//

import FormworkKit
import SafariServices
import SwiftUI

struct ExerciseGuide: View {
    let exercise: Exercise

    @Environment(\.openURL)
    private var openURL: OpenURLAction

    @State
    private var browserURL: URL? = nil

    var body: some View {
        VStack(spacing: 8) {
            if let url = exercise.link {
                Button {
                    if ["http", "https"].contains(url.scheme?.lowercased()) {
                        browserURL = url
                    } else {
                        openURL(url)
                    }
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Label(.sectionExerciseLinkTitle, systemImage: Pictogram.instructions.image)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            if let host = url.host().map({ String($0.trimmingPrefix("www.")) }) {
                                Text(host)
                                    .lineLimit(1)
                            }
                        }

                        Spacer()

                        Image(systemName: "arrow.up.forward")
                            .foregroundStyle(.tertiary)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(.rect(cornerRadius: 16, style: .continuous))
                    .contentShape(.rect(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(.plain)
            }

            VStack(alignment: .leading, spacing: 8) {
                Label(.sectionExerciseNotesTitle, systemImage: Pictogram.notes.image)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                ExerciseNotesField(exercise: exercise)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(.rect(cornerRadius: 16, style: .continuous))
        }
        .padding(.horizontal, 16)
        .fullScreenCover(item: $browserURL) { url in
            SafariView(url: url) {
                browserURL = nil
            }
            .ignoresSafeArea()
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

private struct ExerciseNotesField: View {
    @Bindable
    var exercise: Exercise

    @FocusState
    private var focused: Bool

    @State
    private var editing: Bool = false

    var body: some View {
        TextField(.fieldExerciseNotesPlaceholder, text: $exercise.notes, axis: .vertical)
            .lineLimit(3...)
            .focused($focused)
            .toolbar {
                if editing {
                    ToolbarItem(placement: .confirmationAction) {
                        Button(role: .confirm) {
                            focused = false
                        }
                    }
                }
            }
            .onChange(of: focused) { _, focused in
                withAnimation {
                    editing = focused
                }

                if !focused {
                    exercise.notes = exercise.notes.trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
    }
}

#Preview("Guide") {
    NavigationStack {
        ScrollView {
            VStack(spacing: 32) {
                PictogramHeader(Samples.exercises.first!)

                ExerciseGuide(exercise: Samples.exercises.first!)
            }
        }
    }
    .sampleData()
}
