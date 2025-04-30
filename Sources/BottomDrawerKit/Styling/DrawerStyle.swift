//
//  DrawerStyle.swift
//  BottomDrawerKit
//
//  Created by Arturo Diaz on 4/23/25.
//

import SwiftUI

public struct DrawerStyle: Sendable {
    public enum CornerRadius : Sendable{
        case fixed(CGFloat)
        case device
    }

    public var cornerRadius: CornerRadius
    public var padding: CGFloat

    public init(cornerRadius: CornerRadius = .device, padding: CGFloat = 16) {
        self.cornerRadius = cornerRadius
        self.padding = padding
    }
}

internal extension DrawerStyle {
    var resolvedCornerRadius: CGFloat {
        switch cornerRadius {
        case .fixed(let value): return value
        case .device:
            return MainActor.assumeIsolated {
                UIScreen.main.displayCornerRadius
            }
        }
    }
}

private struct DrawerStyleKey: @preconcurrency EnvironmentKey {
    @MainActor static let defaultValue = DrawerStyle()
}

public extension EnvironmentValues {
    var drawerStyle: DrawerStyle {
        get { self[DrawerStyleKey.self] }
        set { self[DrawerStyleKey.self] = newValue }
    }
}

public extension View {
    func bottomDrawerStyle(_ style: DrawerStyle) -> some View {
        environment(\.drawerStyle, style)
    }
}
