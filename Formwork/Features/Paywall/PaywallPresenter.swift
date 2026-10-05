//
//  PaywallPresenter.swift
//  Formwork
//
//  Created by Daniel Wolbach on 02.10.26.
//

import FormworkUI
import SwiftUI

extension View {
    func paywallPresenter() -> some View {
        modifier(PaywallPresenter())
    }
}

private struct PaywallPresenter: ViewModifier {
    @State
    private var isPresented: Bool = false

    func body(content: Content) -> some View {
        content
            .environment(\.presentPaywall, PresentPaywallAction { isPresented = true })
            .fullScreenCover(isPresented: $isPresented) {
                NavigationRoot {
                    PaywallScreen()
                }
            }
    }
}
