//
//  BottomDrawerEntry.swift
//  BottomDrawerKit
//
//  Created by Arturo Diaz on 4/21/25.
//

import SwiftUI
import UIKit

extension View {
    public func bottomDrawer(
        style: BottomDrawerStyle = .drawer
    ) -> some View {
        modifier(InternalDrawerContainer(style: style))
    }
}

open class BottomDrawerSceneDelegate: NSObject, UIWindowSceneDelegate {
    open var window: UIWindow?

    open func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let rootView = EmptyView()
            .modifier(InternalDrawerContainer(style: .card))
            .ignoresSafeArea()
        
        let host = UIHostingController(rootView: rootView)
        host.view.backgroundColor = .clear

        let window = DrawerWindow(windowScene: windowScene)
        window.rootViewController = host
        window.windowLevel = .alert + 1
        window.isOpaque = false
        window.backgroundColor = .clear
        window.isHidden = false

        self.window = window
    }
}

final class DrawerWindow: UIWindow {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        BottomDrawerRouter.shared.isPresented
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        print("POINT INSIDE: \(point), EVENT: \(String(describing: event))")
        return super.hitTest(point, with: event)
    }
}
