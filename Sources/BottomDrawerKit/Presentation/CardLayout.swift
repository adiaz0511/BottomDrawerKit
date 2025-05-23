//
//  CardPresentationView.swift
//  BottomDrawerKit
//
//  Created by Arturo Diaz on 4/11/25.
//

import SwiftUI

internal struct CardPresentationView<Content: View, ScrollContent: View>: View {
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
    
    let content: Content
    
    @Environment(\.drawerStyle) private var style
    @Environment(\.drawerButtonContext) private var buttonContext

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
        
        withAnimation(animate ? (isPresented ? .interpolatingSpring(stiffness: 230, damping: 20) : .smooth(duration: 0.4)) : .none) {
            height = isPresented ? initialHeight : 0
            contentCornerRadius = UIScreen.main.displayCornerRadius
        }
    }
    
    private var overlayColor: Color {
        let t = max(min(height / maxHeight, 1), 0)
        let tint = cardStyle?.drawerStyleOverride?.overlayTint ?? style.overlayTint ?? .black
        let ratio = cardStyle?.drawerStyleOverride?.overlayTintOpacity ?? style.overlayTintOpacity ?? 0.1
        return tint.opacity(t * ratio)
    }
    
    private var overlayBlurRadius: CGFloat {
        let t = max(min(height / maxHeight, 1), 0)
        return (cardStyle?.drawerStyleOverride?.blurRadius ?? style.blurRadius ?? 0) * t
    }
        
    var body: some View {
        let t = max(min(height / maxHeight, 1), 0)

        ZStack {
            content
                .ignoresSafeArea(.keyboard, edges: .bottom)
                .blur(radius: isPresented ? overlayBlurRadius : 0)

            if isPresented {
                overlayColor
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .animation(.easeInOut, value: isPresented)
                    .onTapGesture {
                        if UIResponder.keyboardIsVisible {
                            dismissKeyboard()
                        } else {
                            if interactiveDismiss {
                                BottomDrawerRouter.shared.dismiss()
                            }
                        }
                    }
            }

            ZStack {
                // The buttons will be inside this container
                VStack(spacing: 0) {
                    dragHandle
                        .opacity(dragHandleVisibility == .hidden ? 0 : 1)
                        .animation(.easeInOut(duration: 0.2), value: dragHandleVisibility)
                    
                    ZStack {
                        scrollContent()
                            .padding(.horizontal, 16)
                            .padding(.bottom, buttonPaddingHeight)
                            .transition(.smoothDrawerReplace)
                    }
                }
                .padding(.top, shouldApplySafeAreaPadding ? safeAreaTopInset : 0)
                // This overlay contains the buttons.
                .overlay(alignment: .bottom) {
                    if leftButton != nil || rightButton != nil {
                        HStack(spacing: 12) {
                            if let left = leftButton {
                                if !hideLeftButton {
                                    DrawerButton(config: left, hideLeftButton: .constant(false))
                                        .transition(.move(edge: .leading).combined(with: .opacity))
                                        .disabled(!(buttonContext?.isSecondaryButtonEnabled ?? true))
                                }
                            }
                            if let right = rightButton {
                                DrawerButton(config: right, hideLeftButton: $hideLeftButton)
                                    .disabled(!(buttonContext?.isPrimaryButtonEnabled ?? true))
                            }
                        }
                        .padding(.horizontal, 30)
                        .padding(.top, 12)
                        .padding(.bottom, 30)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: effectiveCornerRadius, style: .continuous)
                        .fill(cardStyle?.background ?? AnyShapeStyle(Color(.card)))
                        .padding(.all, shouldApplySafeAreaPadding ? -2 : 0)
                )
                .shadow(
                    color: cardStyle?.shadow?.color ?? .clear,
                    radius: cardStyle?.shadow?.radius ?? 0,
                    x: cardStyle?.shadow?.offset.width ?? 0,
                    y: cardStyle?.shadow?.offset.height ?? 0
                )
                .overlay(
                    RoundedRectangle(cornerRadius: effectiveCornerRadius, style: .continuous)
                        .stroke(cardStyle?.borderColor ?? .clear, lineWidth: 1)
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .padding([.horizontal, .bottom], effectivePadding)
                .ignoresSafeArea(.container, edges: .bottom)
                .disabled(!isPresented)
                .onChange(of: isPresented) { oldValue, value in
                    refreshPresentation(animate: true)
                }
                .onAppear {
                    refreshPresentation(animate: false)
                    observeKeyboardChanges(keyboardHeight: $keyboardHeight)
                }
                .padding(.bottom, keyboardHeight == 0 ? 0 : 10)
            }
            .offset(y: commonOffset)
            .ignoresSafeArea(.container, edges: .top)
        }
    }
    
    private var commonOffset: CGFloat {
        max((maxHeight - height) * 1.3, 0)
    }
    
    private var buttonPaddingHeight: CGFloat {
        if leftButton != nil || rightButton != nil {
            return 86 // 44 height + 12 top padding + 30 bottom padding
        }
        return 0
    }
    
    // MARK: - Effective Style Properties
    private var effectiveCornerRadius: CGFloat {
        cardStyle?.drawerStyleOverride?.resolvedCornerRadius ?? style.resolvedCornerRadius
    }

    private var effectivePadding: CGFloat {
        cardStyle?.drawerStyleOverride?.padding ?? style.padding
    }
    
    private var safeAreaTopInset: CGFloat {
        (UIApplication.shared.connectedScenes.first as? UIWindowScene)?
            .windows.first(where: { $0.isKeyWindow })?
            .safeAreaInsets.top ?? 0
    }

    private var shouldApplySafeAreaPadding: Bool {
        initialHeight == UIScreen.main.bounds.height
    }
}
