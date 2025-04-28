//
//  DrawerPresentationView.swift
//  BottomDrawerKit
//
//  Created by Arturo Diaz on 4/11/25.
//

import SwiftUI

internal struct DrawerPresentationView<Content: View, ScrollContent: View>: View {
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
    
    let content: Content
    
    @State private var keyboardHeight: CGFloat = 0
    @State private var hideLeftButton = false
        
    // MARK: Drag gesture configuration
    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { gesture in
                let newHeight = height - gesture.translation.height
                if newHeight > maxHeight {
                    height = maxHeight + (newHeight - maxHeight) * 0.05
                } else {
                    height = max(0, newHeight)
                }
            }
            .onEnded { _ in
                let threshold = initialHeight + (maxHeight - initialHeight) * 0.25

                if height <= 10 {
                    if interactiveDismiss {
                        withAnimation(.bouncy(duration: 0.5)) {
                            height = 0
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            isPresented = false
                            height = 0
                        }
                        return
                    }
                }
                
                if height < initialHeight && height < initialHeight * 0.9 {
                    if interactiveDismiss {
                        withAnimation(.bouncy(duration: 0.5)) {
                            height = 0
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            isPresented = false
                            height = 0
                        }
                        return
                    }
                }

                withAnimation(.bouncy(duration: 0.5)) {
                    if height < threshold {
                        height = initialHeight
                    } else {
                        height = maxHeight
                    }
                }
            }
    }
    
    var dragHandle: some View {
        let t = height / maxHeight
        let width = dragHandleVisibility == .static ? CGFloat(75) : CGFloat(148 + t * (50 - 148)) // manual linear interpolation if not static
        
        let fillOpacity = ((1 - t) + 0.5) * 0.5
        let fillColor = Color.white.opacity(fillOpacity)
        
        return RoundedRectangle(cornerRadius: 100)
            .fill(fillColor)
            .frame(width: width, height: 6)
            .padding(8)
            .contentShape(.rect)
            .gesture(dragGesture)
            .opacity(height != 0 ? 1 : 0)
    }

    
    @State private var contentCornerRadius: CGFloat = 0
    
    private func refreshPresentation(animate: Bool) {
        if isPresented { height = 0 }
        
        withAnimation(animate ? (isPresented ? .interactiveSpring(response: 0.35, dampingFraction: 0.75, blendDuration: 0.2) : .smooth(duration: 0.3)) : .none) {
            height = isPresented ? initialHeight : 0
            contentCornerRadius = isPresented ? UIScreen.main.displayCornerRadius : 0 // TODO: device radius would be cool here!
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .fill(drawerStyle?.background ?? AnyShapeStyle(Color(.card)))
                .ignoresSafeArea(.container, edges: .all)
            
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .disabled(isPresented)
                .background(.background)
                .mask(
                    BottomRoundedRectangle(cornerRadius: contentCornerRadius)
                        .ignoresSafeArea()
                )
                .opacity(isPresented ? 0.95 : 1)
                .onTapGesture {
                    if UIResponder.keyboardIsVisible {
                        dismissKeyboard()
                    } else {
                        if interactiveDismiss {
                            BottomDrawerRouter.shared.dismiss()
                        }
                    }
                }
                .offset(y: isPresented ? -height : 0)
            
            VStack(spacing: 0) {
                dragHandle
                    .opacity(dragHandleVisibility == .hidden ? 0 : 1)
                    .animation(.easeInOut(duration: 0.2), value: dragHandleVisibility)
                
                ZStack {
                    scrollContent()
                        .padding(.bottom, buttonPaddingHeight)
                        .transition(.smoothDrawerReplace)
                }
                
            }
            .frame(height: height)
            .frame(maxWidth: .infinity)
            .overlay(alignment: .bottom) {
                if leftButton != nil || rightButton != nil {
                    HStack(spacing: 12) {
                        if let left = leftButton {
                            if !hideLeftButton {
                                DrawerButton(config: left, hideLeftButton: .constant(false))
                                    .transition(.move(edge: .leading).combined(with: .opacity))
                            }
                        }
                        if let right = rightButton {
                            DrawerButton(config: right, hideLeftButton: $hideLeftButton)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                    .padding(.bottom, 20)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .offset(y: max((maxHeight - height) * 0.7, 0))
                }
            }
            .offset(y: max((maxHeight - height) * 0.7, 0))
            .ignoresSafeArea(.container, edges: .bottom)
            .disabled(!isPresented)
            .onChange(of: isPresented) { oldValue, value in
                refreshPresentation(animate: true)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Group {
                if let style = drawerStyle?.background {
                    Rectangle().fill(style)
                } else {
                    Rectangle().fill(Color(.card))
                }
            }
            .ignoresSafeArea(.container, edges: .bottom)
            .padding(.bottom, -keyboardHeight)
        )
        .offset(y: -keyboardHeight)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onAppear {
            refreshPresentation(animate: false)
            observeKeyboardChanges(keyboardHeight: $keyboardHeight)
        }
    }
    
    private var buttonPaddingHeight: CGFloat {
        if leftButton != nil || rightButton != nil {
            return 76 // 44 height + 12 top padding + 20 bottom padding
        }
        return 0
    }
}
