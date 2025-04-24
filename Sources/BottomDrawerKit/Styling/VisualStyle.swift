//
//  CardVisualStyle.swift
//  BottomDrawerKit
//
//  Created by Arturo Diaz on 4/23/25.
//

import SwiftUI

public struct VisualStyle {
    public var background: AnyShapeStyle
    public var borderColor: Color?
    public var shadow: Shadow?

    public init(
        background: AnyShapeStyle = .init(Color("cardColor", bundle: .main)),
        borderColor: Color? = nil,
        shadow: Shadow? = nil
    ) {
        self.background = background
        self.borderColor = borderColor
        self.shadow = shadow
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
