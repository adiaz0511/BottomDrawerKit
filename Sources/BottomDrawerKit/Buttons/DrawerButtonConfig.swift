//
//  DrawerButtonConfig.swift
//  BottomDrawerKit
//
//  Created by Arturo Diaz on 4/22/25.
//

import SwiftUI

public struct DrawerButtonConfig: Equatable {
    public let title: String
    public let icon: String?
    public let backgroundColor: Color
    public let borderColor: Color
    public let shape: DrawerButtonShape
    public let hapticFeedback: HapticFeedbackType?
    public let action: () -> Void

    public static func == (lhs: DrawerButtonConfig, rhs: DrawerButtonConfig) -> Bool {
        return lhs.title == rhs.title &&
               lhs.icon == rhs.icon &&
               lhs.backgroundColor == rhs.backgroundColor &&
               lhs.borderColor == rhs.borderColor &&
               lhs.shape == rhs.shape
    }
    
    public init(
        title: String,
        icon: String? = nil,
        backgroundColor: Color,
        borderColor: Color,
        shape: DrawerButtonShape = .capsule,
        hapticFeedback: HapticFeedbackType? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.shape = shape
        self.hapticFeedback = hapticFeedback
        self.action = action
    }
}

public enum HapticFeedbackType {
    case light
    case medium
    case heavy

    @MainActor func generate() {
        let generator: UIImpactFeedbackGenerator
        switch self {
        case .light:
            generator = UIImpactFeedbackGenerator(style: .light)
        case .medium:
            generator = UIImpactFeedbackGenerator(style: .medium)
        case .heavy:
            generator = UIImpactFeedbackGenerator(style: .heavy)
        }
        generator.impactOccurred()
    }
}
