//
//  BottomDrawerKitExampleApp.swift
//  BottomDrawerKitExample
//
//  Created by Arturo Diaz on 4/23/25.
//

import SwiftUI
import BottomDrawerKit

@main
struct BottomDrawerKitExampleApp: App {
    @State var style = BottomDrawerStyle.drawer

    var body: some Scene {
        WindowGroup {
            ContentView(style: $style)
                .bottomDrawer(style: style)
                .environment(\.bottomDrawerRouter, BottomDrawerRouter.shared)
                .environment(\.drawerStyle, DrawerStyle(cornerRadius: .device, padding: 8))
        }
    }
}
