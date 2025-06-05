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
    @State private var style: BottomDrawerStyle = .drawer
    let buttonContext: DrawerButtonContext = .init()
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
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

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        configurationForConnecting session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let config = UISceneConfiguration(name: nil, sessionRole: session.role)
        config.delegateClass = BottomDrawerSceneDelegate.self
        return config
    }
}
