//
//  BottomDrawerModifier .swift
//  BottomDrawerKit
//
//  Created by Arturo Diaz on 4/21/25.
//

import SwiftUI

internal struct BottomDrawer<ScrollContent: View>: ViewModifier {
    let initialHeight: CGFloat
    let maxHeight:     CGFloat
    
    let scrollContent: () -> ScrollContent
    
    let dragHandleVisibility: DragHandleVisibility
    
    @Binding var height: CGFloat
    
    @Environment(\.colorScheme) private var colorScheme
    
    @Binding var isPresented: Bool
    
    let interactiveDismiss: Bool
    
    let leftButton: DrawerButtonConfig?
    let rightButton: DrawerButtonConfig?
    let drawerStyle: VisualStyle?
                
    func body(content: Content) -> some View {
        DrawerPresentationView(
            initialHeight: initialHeight,
            maxHeight: maxHeight,
            scrollContent: { scrollContent() },
            dragHandleVisibility: dragHandleVisibility,
            height: $height,
            isPresented: $isPresented,
            interactiveDismiss: interactiveDismiss,
            leftButton: leftButton,
            rightButton: rightButton,
            drawerStyle: drawerStyle,
            content: content
        )
    }
}

internal struct BottomCard<ScrollContent: View>: ViewModifier {
    let initialHeight: CGFloat
    let maxHeight:     CGFloat
    
    let scrollContent: () -> ScrollContent
    
    let dragHandleVisibility: DragHandleVisibility
    
    @Binding var height: CGFloat
    
    @Environment(\.colorScheme) private var colorScheme
    
    @Binding var isPresented: Bool
    
    let interactiveDismiss: Bool
    
    let leftButton: DrawerButtonConfig?
    let rightButton: DrawerButtonConfig?
    let cardStyle: VisualStyle?
                
    func body(content: Content) -> some View {
        CardPresentationView(
            initialHeight: initialHeight,
            maxHeight: maxHeight,
            scrollContent: { scrollContent() },
            dragHandleVisibility: dragHandleVisibility,
            height: $height,
            isPresented: $isPresented,
            interactiveDismiss: interactiveDismiss,
            leftButton: leftButton,
            rightButton: rightButton,
            cardStyle: cardStyle,
            content: content
        )
    }
}
