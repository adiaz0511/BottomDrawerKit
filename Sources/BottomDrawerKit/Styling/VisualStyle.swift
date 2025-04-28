//
//  CardVisualStyle.swift
//  BottomDrawerKit
//
//  Created by Arturo Diaz on 4/23/25.
//

import SwiftUI

public let drawerDefaultColor = Color(.card)

public struct VisualStyle {
    public var background: AnyShapeStyle
    public var borderColor: Color?
    public var shadow: Shadow?
    public var drawerStyleOverride: DrawerStyle?

    public init(
        background: AnyShapeStyle = AnyShapeStyle(drawerDefaultColor),
        borderColor: Color? = nil,
        shadow: Shadow? = nil,
        drawerStyleOverride: DrawerStyle? = nil
    ) {
        self.background = background
        self.borderColor = borderColor
        self.shadow = shadow
        self.drawerStyleOverride = drawerStyleOverride
    }

    public struct Shadow {
        public var color: Color
        public var radius: CGFloat
        public var offset: CGSize

        public init(color: Color, radius: CGFloat, offset: CGSize = .zero) {
            self.color = color
            self.radius = radius
            self.offset = offset
        }
    }
}
