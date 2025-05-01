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
                .injectBottomDrawerRouter()
                .drawerButtonContext(buttonContext)
                .bottomDrawerStyle(
                    .init(
                        cornerRadius: .device,
                        padding: 8,
                        blurRadius: 0,
                        overlayTint: .black,
                        overlayTintOpacity: 0.1
                    )
                )
                .onAppear {
                    BottomDrawerRouter.setLogging(false)

                    BottomDrawerRouter.onRouteChange = { change, stack in
                        switch change {
                        case .present(let route):
                            print("🟢 Presented route: \(route)")
                        case .pop(let previous, let newTop):
                            print("🔵 Popped route: \(previous)")
                            if let newTop = newTop {
                                print("🔝 New top route: \(newTop)")
                            } else {
                                print("🔝 Stack is now empty")
                            }
                        case .popToRoot:
                            print("🔙 Popped to root")
                        case .dismiss:
                            print("❌ Dismissed all routes")
                        }
                    }
                }
        }
    }
}
