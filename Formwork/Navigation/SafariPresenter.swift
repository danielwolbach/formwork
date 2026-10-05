//
//  SafariPresenter.swift
//  Formwork
//
//  Created by Daniel Wolbach on 05.10.26.
//

import SafariServices
import SwiftUI

extension View {
    func safariPresenter() -> some View {
        modifier(SafariPresenter())
    }
}

private struct SafariPresenter: ViewModifier {
    private struct Page: Identifiable {
        let url: URL

        var id: URL {
            url
        }
    }

    @State
    private var page: Page?

    func body(content: Content) -> some View {
        content
            .environment(\.openURL, OpenURLAction { url in
                guard ["http", "https"].contains(url.scheme?.lowercased()) else {
                    return .systemAction
                }

                page = Page(url: url)
                return .handled
            })
            .fullScreenCover(item: $page) { page in
                SafariView(url: page.url) {
                    self.page = nil
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
