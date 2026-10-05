//
//  CancelButton.swift
//  Formwork
//
//  Created by Daniel Wolbach on 05.10.26.
//

import FormworkUI
import SwiftUI

struct CancelButton: View {
    private let hasChanges: Bool

    @Environment(\.dismiss)
    private var dismiss: DismissAction

    @State
    private var discardChangesAlert: Bool = false

    init(hasChanges: Bool = false) {
        self.hasChanges = hasChanges
    }

    var body: some View {
        Button(.cancel) {
            if hasChanges {
                discardChangesAlert = true
            } else {
                dismiss()
            }
        }
        .alert(.alertDiscardChangesTitle, isPresented: $discardChangesAlert) {
            Button(.keepEditing) {
                // Works automatically.
            }

            Button(.discardChanges) {
                dismiss()
            }
        } message: {
            Text(.alertDiscardChangesMessage)
        }
    }
}
