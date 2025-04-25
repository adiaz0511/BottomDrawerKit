//
//  Keyboard+Visibility.swift
//  BottomDrawerKit
//
//  Created by Arturo Diaz on 4/22/25.
//

import SwiftUI

extension UIResponder {
    internal static var keyboardIsVisible: Bool {
        UIApplication.shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .contains { $0.isFirstResponderInHierarchy }
    }
}

private extension UIWindow {
    var isFirstResponderInHierarchy: Bool {
        self.rootViewController?.view.findFirstResponder() != nil
    }
}

private extension UIView {
    func findFirstResponder() -> UIView? {
        if isFirstResponder {
            return self
        }
        for subview in subviews {
            if let responder = subview.findFirstResponder() {
                return responder
            }
        }
        return nil
    }
}

internal func observeKeyboardChanges(keyboardHeight: Binding<CGFloat>) {
    NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: .main) { notification in
        guard
            let info = notification.userInfo,
            let frame = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else { return }

        Task { @MainActor in
            let screenHeight = UIScreen.main.bounds.height
            let visibleHeight = max(0, screenHeight - frame.origin.y)
            withAnimation(.smooth()) {
                keyboardHeight.wrappedValue = visibleHeight - 40
            }
        }
    }

    NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
        Task { @MainActor in
            withAnimation(.smooth()) {
                keyboardHeight.wrappedValue = 0
            }
        }
    }
}

@MainActor
func dismissKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}
