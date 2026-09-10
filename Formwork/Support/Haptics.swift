//
//  Haptics.swift
//  Formwork
//
//  Created by Daniel Wolbach on 06.09.26.
//

import UIKit

enum Haptics {
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle, intensity: CGFloat = 1) {
        UIImpactFeedbackGenerator(style: style).impactOccurred(intensity: intensity)
    }

    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }
}
