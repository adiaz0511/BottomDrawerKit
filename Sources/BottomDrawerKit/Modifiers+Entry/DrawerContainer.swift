//
//  DrawerContainer.swift
//  BottomDrawerKit
//
//  Created by Arturo Diaz on 4/21/25.
//

import SwiftUI

internal struct InternalDrawerContainer: ViewModifier {
    let style: BottomDrawerStyle
    @Environment(\.drawerButtonContext) private var buttonContext

    func body(content: Content) -> some View {
        let router = BottomDrawerRouter.shared
        let screenHeight = UIScreen.main.bounds.height
        let resolvedInitialHeight = router.config.initialHeight.resolved(using: screenHeight)
        let resolvedMaxHeight = router.config.maxHeight.resolved(using: screenHeight)

        let drawerContent: AnyView = {
            if let content = router.content {
                return content
            } else {
                return AnyView(EmptyView())
            }
        }()

        switch style {
        case .drawer:
            return AnyView(
                content
                    .environment(\.bottomDrawerRouter, router)
                    .environment(\.drawerButtonContext, buttonContext)
                    .modifier(BottomDrawer(
                        initialHeight: resolvedInitialHeight,
                        maxHeight: resolvedMaxHeight,
                        scrollContent: { drawerContent },
                        dragHandleVisibility: router.config.dragHandleVisibility,
                        height: router.heightBinding,
                        isPresented: router.isPresentedBinding,
                        interactiveDismiss: router.config.interactiveDismiss,
                        leftButton: router.config.secondaryButton,
                        rightButton: router.config.primaryButton,
                        drawerStyle: router.config.visualStyle
                    ))
            )
        case .card:
            return AnyView(
                content
                    .environment(\.bottomDrawerRouter, router)
                    .environment(\.drawerButtonContext, buttonContext)
                    .modifier(BottomCard(
                        initialHeight: resolvedInitialHeight,
                        maxHeight: resolvedMaxHeight,
                        scrollContent: { drawerContent },
                        dragHandleVisibility: router.config.dragHandleVisibility,
                        height: router.heightBinding,
                        isPresented: router.isPresentedBinding,
                        interactiveDismiss: router.config.interactiveDismiss,
                        leftButton: router.config.secondaryButton,
                        rightButton: router.config.primaryButton,
                        cardStyle: router.config.visualStyle
                    ))
            )
        }
    }
}
