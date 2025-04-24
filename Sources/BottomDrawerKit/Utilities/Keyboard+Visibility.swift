//
//  Keyboard+Visibility.swift
//  BottomDrawerKit
//
//  Created by Arturo Diaz on 4/22/25.
//

import UIKit

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
