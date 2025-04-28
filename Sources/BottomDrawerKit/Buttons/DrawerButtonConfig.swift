//
//  DrawerButtonConfig.swift
//  BottomDrawerKit
//
//  Created by Arturo Diaz on 4/22/25.
//

import SwiftUI

public protocol RetryableError: Error {
    var retryTitle: String? { get }
}

public struct DrawerButtonConfig: Equatable {
    public let title: String
    public let icon: String?
    public let backgroundColor: Color
    public let borderColor: Color
    public let shape: DrawerButtonShape
    public let hapticFeedback: HapticFeedbackType?
    public let action: (() -> Void)?
    public let asyncConfig: DrawerButtonAsyncConfig?

    public init(
        title: String,
        icon: String? = nil,
        backgroundColor: Color,
        borderColor: Color,
        shape: DrawerButtonShape = .capsule,
        hapticFeedback: HapticFeedbackType? = nil,
        action: (() -> Void)? = nil,
        asyncConfig: DrawerButtonAsyncConfig? = nil
    ) {
        self.title = title
        self.icon = icon
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.shape = shape
        self.hapticFeedback = hapticFeedback
        self.action = action
        self.asyncConfig = asyncConfig
    }

    public static func == (lhs: DrawerButtonConfig, rhs: DrawerButtonConfig) -> Bool {
        return lhs.title == rhs.title &&
               lhs.icon == rhs.icon &&
               lhs.backgroundColor == rhs.backgroundColor &&
               lhs.borderColor == rhs.borderColor &&
               lhs.shape == rhs.shape
    }
}

// MARK: - Async Support

public struct DrawerButtonAsyncConfig {
    public let asyncAction: () async throws -> Result<String?, Error>
    public let hidesLeftButtonOnTap: Bool
    public let errorAppearance: DrawerButtonStateAppearance?
    public let tryAgainAppearance: DrawerButtonStateAppearance?
    public let successAppearance: DrawerButtonStateAppearance?
    public let actionAfterSuccess: DrawerButtonActionAfterSuccess
    public let maxRetryCount: Int?
    public let actionAfterMaxRetries: DrawerButtonActionAfterSuccess?

    public init(
        asyncAction: @escaping () async throws -> Result<String?, Error>,
        hidesLeftButtonOnTap: Bool = true,
        errorAppearance: DrawerButtonStateAppearance? = nil,
        tryAgainAppearance: DrawerButtonStateAppearance? = nil,
        successAppearance: DrawerButtonStateAppearance? = nil,
        actionAfterSuccess: DrawerButtonActionAfterSuccess = .noAction,
        maxRetryCount: Int? = 0,
        actionAfterMaxRetries: DrawerButtonActionAfterSuccess? = nil
    ) {
        self.asyncAction = asyncAction
        self.hidesLeftButtonOnTap = hidesLeftButtonOnTap
        self.errorAppearance = errorAppearance
        self.tryAgainAppearance = tryAgainAppearance
        self.successAppearance = successAppearance
        self.actionAfterSuccess = actionAfterSuccess
        self.maxRetryCount = maxRetryCount
        self.actionAfterMaxRetries = actionAfterMaxRetries
    }
}

public enum DrawerButtonActionAfterSuccess {
    case noAction
    case pop
    case dismiss
}

public struct DrawerButtonStateAppearance {
    public let icon: String
    public let backgroundColor: Color
    public let borderColor: Color?
    public let title: String?
    public let hapticFeedbackOnCompletion: HapticFeedbackType?

    public init(
        icon: String,
        backgroundColor: Color,
        borderColor: Color? = nil,
        title: String? = nil,
        hapticFeedbackOnCompletion: HapticFeedbackType? = nil
    ) {
        self.icon = icon
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.title = title
        self.hapticFeedbackOnCompletion = hapticFeedbackOnCompletion
    }
}

// MARK: - Haptics

public enum HapticFeedbackType {
    case light
    case medium
    case heavy
    case success
    case warning
    case error

    @MainActor
    func generate() {
        switch self {
        case .light:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .medium:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .heavy:
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        case .success:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .warning:
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        case .error:
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }
}
