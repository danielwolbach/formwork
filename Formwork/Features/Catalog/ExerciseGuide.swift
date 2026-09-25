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
            if let url = exercise.url {
                Button {
                    if ["http", "https"].contains(url.scheme?.lowercased()) {
                        browserURL = url
                    } else {
                        openURL(url)
                    }
                } label: {
                    HStack {
                        Image(systemName: Pictogram.instructions.image)
                            .font(.system(size: 24))
                            .foregroundStyle(Pictogram.instructions.color)
                            .frame(width: 48, height: 48)
            
                        VStack(alignment: .leading) {
                            Text(.sectionExerciseLinkTitle)
                                .lineLimit(1)
                                .font(.headline)
                            
                            if let host = url.host().map({ String($0.trimmingPrefix("www.")) }) {
                                Text(host)
                                    .lineLimit(1)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        Image(systemName: "arrow.up.forward")
                            .foregroundStyle(.tertiary)
                    }
                    .padding()
                    .background(Pictogram.instructions.color.quinary)
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
    let url: URL
    
    let onDone: () -> Void
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let controller = SFSafariViewController(url: url)
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ controller: SFSafariViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onDone: onDone)
    }
    
    final class Coordinator: NSObject, SFSafariViewControllerDelegate {
        private let onDone: () -> Void
        
        init(onDone: @escaping () -> Void) {
            self.onDone = onDone
        }
        
        func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            onDone()
        }
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
