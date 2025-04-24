//
//  BottomDrawerRoute.swift
//  BottomDrawerKitExample
//
//  Created by Arturo Diaz on 4/23/25.
//

import SwiftUI
import BottomDrawerKit

enum BottomDrawerDemoRoute: BottomDrawerRouteable, Identifiable {
    case actionButtons
    case showCard
    case colorPicker
    case nameInput
    case colorScheme
    case deleteConfirmation

    var id: String { String(describing: self) }

    var config: Config {
        switch self {
        case .actionButtons:
            return .init(
                interactiveDismiss: true,
                dragHandleVisibility: .visible,
                height: .fraction(0.3),
                initialHeight: .fraction(0.3),
                maxHeight: .fraction(0.3),
                rightButton: DrawerButtonConfig(
                    title: "Delete",
                    icon: "trash",
                    backgroundColor: .red,
                    borderColor: .white.opacity(0.2),
                    shape: .capsule,
                    action: {
                        Task {
                            await BottomDrawerRouter.present(BottomDrawerDemoRoute.deleteConfirmation)
                        }
                    }
                ),
                onDismissAsync: {
                    try? await Task.sleep(nanoseconds: 400_000_000)
                    print("Async dismiss complete")
                }
            )

        case .showCard:
            return .init(
                interactiveDismiss: true,
                dragHandleVisibility: .visible,
                height: .fraction(0.88),
                initialHeight: .fraction(0.88),
                maxHeight: .fraction(0.88)
            )
            
        case .colorPicker:
            return .init(
                interactiveDismiss: true,
                dragHandleVisibility: .visible,
                height: .fraction(0.55),
                initialHeight: .fraction(0.55),
                maxHeight: .fraction(0.55),
                leftButton: DrawerButtonConfig(
                    title: "Back",
                    icon: "arrow.uturn.backward",
                    backgroundColor: Color(hex: "48484a"),
                    borderColor: .clear,
                    shape: .rounded(16),
                    action: {
                        Task {
                            await BottomDrawerRouter.pop()
                        }
                    }
                ),
                rightButton: DrawerButtonConfig(
                    title: "Save",
                    icon: nil,
                    backgroundColor: .white,
                    borderColor: .clear,
                    shape: .rounded(16),
                    action: {
                        print("Save tapped")
                    }
                )
            )
            
        case .nameInput:
            return .init(
                interactiveDismiss: true,
                dragHandleVisibility: .visible,
                height: .fraction(0.25),
                initialHeight: .fraction(0.25),
                maxHeight: .fraction(0.25),
                leftButton: DrawerButtonConfig(
                    title: "Back",
                    icon: "arrow.uturn.backward",
                    backgroundColor: Color(hex: "48484a"),
                    borderColor: .clear,
                    shape: .rounded(16),
                    action: {
                        Task {
                            await BottomDrawerRouter.pop()
                        }
                    }
                ),
                rightButton: DrawerButtonConfig(
                    title: "Save",
                    icon: nil,
                    backgroundColor: .white,
                    borderColor: .clear,
                    shape: .rounded(16),
                    action: {
                        print("Save tapped")
                    }
                )
            )
        case .colorScheme:
            return .init(
                interactiveDismiss: true,
                dragHandleVisibility: .visible,
                height: .fraction(0.35),
                initialHeight: .fraction(0.35),
                maxHeight: .fraction(0.35),
                rightButton: DrawerButtonConfig(
                    title: "Back",
                    icon: "arrow.uturn.backward",
                    backgroundColor: Color(hex: "48484a"),
                    borderColor: .clear,
                    shape: .rounded(16),
                    action: {
                        Task {
                            await BottomDrawerRouter.pop()
                        }
                    }
                )
            )
        case .deleteConfirmation:
            return .init(
                interactiveDismiss: true,
                dragHandleVisibility: .visible,
                height: .fraction(0.25),
                initialHeight: .fraction(0.25),
                maxHeight: .fraction(0.25),
                leftButton: DrawerButtonConfig(
                    title: "Back",
                    icon: "arrow.uturn.backward",
                    backgroundColor: .clear,
                    borderColor: .white,
                    shape: .rounded(16),
                    action: {
                        Task {
                            await BottomDrawerRouter.pop()
                        }
                    }
                ),
                rightButton: DrawerButtonConfig(
                    title: "Yes, Delete",
                    icon: nil,
                    backgroundColor: .white,
                    borderColor: .white.opacity(0.2),
                    shape: .rounded(16),
                    action: {
                        BottomDrawerRouter.dismiss()
                    }
                ),
                visualStyle: VisualStyle(
                    background: AnyShapeStyle(Color.red),
                    borderColor: Color(hex: "6B0F1A")
                )
            )
        }
    }

    @ViewBuilder
    func view() -> any View {
        switch self {
        case .actionButtons:
            ActionButtonsView()
        case .showCard:
            ShowCardView()
        case .colorPicker:
            ColorPickerView()
        case .nameInput:
            NameInputView()
        case .colorScheme:
            ColorSchemeView()
        case .deleteConfirmation:
            DeleteOptionView(
                title: "Delete Account",
                subtitle: "You will have 30 days to recover your account."
            )
        }
    }
}
