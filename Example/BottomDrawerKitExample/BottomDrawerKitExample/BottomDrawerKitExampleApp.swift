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
    let buttonContext: DrawerButtonContext = .init()
    
    var body: some Scene {
        WindowGroup {
            ContentView(style: $style)
                .bottomDrawer(style: style)
                .bottomDrawerRouter(BottomDrawerRouter.shared)
                .drawerButtonContext(buttonContext)
                .bottomDrawerStyle(.init(cornerRadius: .device, padding: 8))
        }
    }
}
