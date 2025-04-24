//
//  DrawerReplaceTransition.swift
//  BottomDrawerKit
//
//  Created by Arturo Diaz on 4/22/25.
//

import SwiftUI

extension AnyTransition {
    internal static var smoothDrawerReplace: AnyTransition {
        .asymmetric(
            insertion: .modifier(
                active: DrawerReplaceTransition(opacity: 0, blur: 20, scale: 0.7),
                identity: DrawerReplaceTransition(opacity: 1, blur: 0, scale: 1)
            ),
            removal: .modifier(
                active: DrawerReplaceTransition(opacity: 0, blur: 20, scale: 0.7),
                identity: DrawerReplaceTransition(opacity: 1, blur: 0, scale: 1)
            )
        )
    }
}

fileprivate struct DrawerReplaceTransition: ViewModifier {
    let opacity: Double
    let blur: CGFloat
    let scale: CGFloat

    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .blur(radius: blur)
            .scaleEffect(scale)
    }
}
