//
//  BottomDrawerEntry.swift
//  BottomDrawerKit
//
//  Created by Arturo Diaz on 4/21/25.
//

import SwiftUI

extension View {
    public func bottomDrawer(
        style: BottomDrawerStyle = .drawer
    ) -> some View {
        modifier(InternalDrawerContainer(style: style))
    }
}
