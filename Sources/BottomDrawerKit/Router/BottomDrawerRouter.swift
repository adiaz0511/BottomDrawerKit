//
//  BottomDrawerRouter.swift
//  BottomDrawerKit
//
//  Created by Arturo Diaz on 4/21/25.
//

import SwiftUI
import Observation

@Observable
public final class BottomDrawerRouter: @unchecked Sendable {
    private init() {}
    public static let shared = BottomDrawerRouter()
    internal var stack: [any BottomDrawerRouteable] = []

    internal var isPresented: Bool = false
    internal var height: CGFloat = 0
    internal var config: Config = .init(
        interactiveDismiss: true,
        dragHandleVisibility: .visible,
        height: .fraction(0.3),
        initialHeight: .fraction(0.3),
        maxHeight: .fraction(0.3)
    )
    internal var content: AnyView?
    
    private var onDismissCallback: (() -> Void)?
    private var onDismissAsyncCallback: (() async -> Void)?
    
    
    @MainActor func present(_ route: any BottomDrawerRouteable) {
        print("[BottomDrawerRouter] Presenting route: \(route)")
        stack.append(route)
        print("[BottomDrawerRouter] Stack after present: \(stack)")
        applyTopRoute()
    }
    
    @MainActor private func applyTopRoute() {
        let screenHeight = UIScreen.main.bounds.height
        let top = stack.last!
        print("[BottomDrawerRouter] Applying top route: \(String(describing: stack.last))")
        
        if content == nil {
            self.content = AnyView(top.view())
        } else {
            withAnimation(.easeInOut(duration: 0.25)) {
                self.content = AnyView(top.view())
            }
        }

        self.onDismissCallback = top.config.onDismiss
        self.onDismissAsyncCallback = top.config.onDismissAsync

        withAnimation(.smooth(duration: 0.35, extraBounce: 0.02)) {
            self.config = top.config
            self.height = top.config.initialHeight.resolved(using: screenHeight)
        }
        
        DispatchQueue.main.async {
            self.isPresented = true
        }
    }
    
    @MainActor func pop() {
        print("[BottomDrawerRouter] Popping route. Stack count before: \(stack.count)")
 
        var didResignFirstResponder = false
 
        // Try to dismiss the keyboard if active
        if UIResponder.keyboardIsVisible {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            didResignFirstResponder = true
        }
 
        let delay: DispatchTimeInterval = didResignFirstResponder ? .milliseconds(350) : .milliseconds(0)
 
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            guard self.stack.count > 1 else {
                print("[BottomDrawerRouter] Only one route in stack. Pop ignored.")
                return
            }
 
            self.stack.removeLast()
            print("[BottomDrawerRouter] Stack after pop: \(self.stack)")
            self.applyTopRoute()
        }
    }

    @MainActor func popToRoot() {
        print("[BottomDrawerRouter] Popping to root. Stack count before: \(stack.count)")
        guard !stack.isEmpty else { return }

        stack = [stack.first!]
        print("[BottomDrawerRouter] Stack after popToRoot: \(stack)")
        applyTopRoute()
    }

    func dismiss() {
        print("[BottomDrawerRouter] Dismissing drawer. Stack will be cleared.")
        withAnimation {
            self.isPresented = false

            Task {
                if let onDismissAsyncCallback {
                    await onDismissAsyncCallback()
                    self.onDismissAsyncCallback = nil
                } else {
                    self.onDismissCallback?()
                    self.onDismissCallback = nil
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    self.stack.removeAll()
                    print("[BottomDrawerRouter] Stack after dismiss: \(self.stack)")
                }
            }
        }
    }
    
    @MainActor
    public func presentRoute(_ route: any BottomDrawerRouteable) {
        self.present(route)
    }

    @MainActor
    public func popRoute() {
        self.pop()
    }

    @MainActor
    public func popToRootRoute() {
        self.popToRoot()
    }

    public func dismissRoutes() {
        self.dismiss()
    }
}

extension BottomDrawerRouter {
    internal var heightBinding: Binding<CGFloat> {
        Binding(
            get: { self.height },
            set: { self.height = $0 }
        )
    }

    internal var isPresentedBinding: Binding<Bool> {
        Binding(
            get: { self.isPresented },
            set: { self.isPresented = $0 }
        )
    }
}

extension BottomDrawerRouter {
    @MainActor public static func present(_ route: any BottomDrawerRouteable) {
        shared.present(route)
    }

    @MainActor public static func pop() {
        shared.pop()
    }

    @MainActor public static func popToRoot() {
        shared.popToRoot()
    }

    public static func dismiss() {
        shared.dismiss()
    }
}
