//
//  DrawerButtonContext.swift
//  BottomDrawerKit
//
//  Created by Arturo Diaz on 4/27/25.
//

import SwiftUI
import Observation

// MARK: - DrawerButtonContext

@Observable
public final class DrawerButtonContext {
    public var isPrimaryButtonEnabled: Bool = true
    public var isSecondaryButtonEnabled: Bool = true

    public init() {}
}

// MARK: - Environment Key

private struct DrawerButtonContextKey: @preconcurrency EnvironmentKey {
    @MainActor static let defaultValue: DrawerButtonContext? = nil
}

// MARK: - EnvironmentValues extension

public extension EnvironmentValues {
    var drawerButtonContext: DrawerButtonContext? {
        get { self[DrawerButtonContextKey.self] }
        set { self[DrawerButtonContextKey.self] = newValue }
    }
}

public extension View {
    func drawerButtonContext(_ context: DrawerButtonContext) -> some View {
        environment(\.drawerButtonContext, context)
    }
}
