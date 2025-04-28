//
//  BottomDrawerRouteable.swift
//  BottomDrawerKit
//
//  Created by Arturo Diaz on 4/21/25.
//

import SwiftUI

public protocol BottomDrawerRouteable: Identifiable, Hashable {
    var config: Config { get }
    @ViewBuilder func view() -> any View
}

public struct Config {
    public var interactiveDismiss: Bool
    public var dragHandleVisibility: DragHandleVisibility
    public var height: DrawerHeight
    public var initialHeight: DrawerHeight
    public var maxHeight: DrawerHeight
    public var primaryButton: DrawerButtonConfig? = nil
    public var secondaryButton: DrawerButtonConfig? = nil
    public var visualStyle: VisualStyle? = nil
    public var onDismiss: (() -> Void)? = nil
    public var onDismissAsync: (() async -> Void)? = nil
    
    public init(
        interactiveDismiss: Bool = true,
        dragHandleVisibility: DragHandleVisibility = .visible,
        height: DrawerHeight,
        initialHeight: DrawerHeight = .fraction(0.2),
        maxHeight: DrawerHeight = .fraction(1.0),
        primaryButton: DrawerButtonConfig? = nil,
        secondaryButton: DrawerButtonConfig? = nil,
        visualStyle: VisualStyle? = nil,
        onDismiss: (() -> Void)? = nil,
        onDismissAsync: (() async -> Void)? = nil
    ) {
        self.interactiveDismiss = interactiveDismiss
        self.dragHandleVisibility = dragHandleVisibility
        self.height = height
        self.initialHeight = initialHeight
        self.maxHeight = maxHeight
        self.primaryButton = primaryButton
        self.secondaryButton = secondaryButton
        self.visualStyle = visualStyle
        self.onDismiss = onDismiss
        self.onDismissAsync = onDismissAsync
    }
}

public enum DrawerHeight {
    case fraction(CGFloat)
    case points(CGFloat)
}

extension DrawerHeight {
    internal func resolved(using screenHeight: CGFloat) -> CGFloat {
        switch self {
        case .fraction(let value):
            // Use a dynamic adjustment based on screen height
            let clampedScreenHeight = min(max(screenHeight, 600), 932) // SE to Pro Max
            let scale = (clampedScreenHeight - 600) / (932 - 600) // 0 to 1
            let reduction: CGFloat = clampedScreenHeight >= 900 ? 0.09 * scale : 0
            let adjustedFraction = value * (1 - reduction)
            return adjustedFraction * screenHeight
        case .points(let value):
            return value
        }
    }
}

public enum BottomDrawerStyle {
    case drawer
    case card
}


public enum DragHandleVisibility {
    case visible
    case `static`
    case hidden
}
