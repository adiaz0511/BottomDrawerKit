//
//  BottomDrawerEnvironment.swift
//  BottomDrawerKit
//
//  Created by Arturo Diaz on 4/22/25.
//

import SwiftUI

internal struct BottomDrawerRouterKey: EnvironmentKey {
    static let defaultValue = BottomDrawerRouter.shared
}

extension EnvironmentValues {
    public var bottomDrawerRouter: BottomDrawerRouter {
        get { self[BottomDrawerRouterKey.self] }
        set { self[BottomDrawerRouterKey.self] = newValue }
    }
}
