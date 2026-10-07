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
    func body(content: Content) -> some View {
        content
            .environment(\.openURL, OpenURLAction { url in
                guard ["http", "https"].contains(url.scheme?.lowercased()), let presenter = topViewController() else {
                    return .systemAction
                }

                // Safari dismisses itself on Done, so a SwiftUI cover would dismiss twice and close what's underneath.
                presenter.present(SFSafariViewController(url: url), animated: true)
                return .handled
            })
    }

    private func topViewController() -> UIViewController? {
        let scene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }

        var controller = scene?.keyWindow?.rootViewController
        while let presented = controller?.presentedViewController, !presented.isBeingDismissed {
            controller = presented
        }
        return controller
    }
}
