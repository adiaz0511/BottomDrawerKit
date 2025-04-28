//
//  DrawerButton.swift
//  BottomDrawerKit
//
//  Created by Arturo Diaz on 4/22/25.
//

import SwiftUI

public enum DrawerButtonShape: Equatable {
    case rounded(CGFloat)
    case capsule
}

internal struct DrawerButton: View {
    let config: DrawerButtonConfig
    @Binding var hideLeftButton: Bool
    @State private var previousConfig: DrawerButtonConfig? = nil
    @State private var isTransitioning = false
    @State private var buttonState: DrawerButtonState = .idle
    @State private var dynamicTitle: String? = nil
    @State private var retryCount: Int = 0
    @State private var isInRetryMode: Bool = false

    private enum DrawerButtonState {
        case idle
        case loading
        case success
        case error
    }

    var body: some View {
        Button(action: {
            config.hapticFeedback?.generate()
            if let asyncAction = config.asyncConfig?.asyncAction {
                Task {
                    await performAsyncAction(asyncAction)
                }
            } else if let action = config.action {
                action()
            }
        }) {
            Color.clear
                .frame(height: 54)
                .frame(maxWidth: .infinity)
                .background(
                    ZStack {
                        backgroundColor(for: buttonState)
                            .clipShape(shapeView)

                        ZStack {
                            if buttonState == .loading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: foregroundColor(for: backgroundColor(for: buttonState))))
                            } else {
                                HStack(spacing: 8) {
                                    if let iconName = currentIconName(for: buttonState) {
                                        Image(systemName: iconName)
                                    }
                                    Text(currentTitle(for: buttonState))
                                }
                                .font(.headline)
                                .foregroundColor(foregroundColor(for: backgroundColor(for: buttonState)))
                                .blur(radius: isTransitioning ? 6 : 0)
                                .animation(.easeInOut(duration: 0.18), value: isTransitioning)
                                .contentTransition(.numericText())
                            }
                        }
                        .padding(.horizontal)
                    }
                )
                .overlay(
                    shapeView
                        .stroke(borderColor(for: buttonState), lineWidth: 2)
                )
        }
        .disabled(buttonState != .idle)
        .onChange(of: config.title) { _, _ in
            if previousConfig == nil {
                previousConfig = config
            }

            isTransitioning = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                isTransitioning = false
                previousConfig = nil
            }
        }
        .onChange(of: config.title) { _, _ in
            buttonState = .idle
            retryCount = 0
        }
        .onChange(of: buttonState) { _, _ in
            isTransitioning = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                isTransitioning = false
            }
        }
    }

    private func performAsyncAction(_ asyncAction: @escaping () async throws -> Result<String?, Error>) async {
        if config.asyncConfig?.hidesLeftButtonOnTap ?? false {
            withAnimation(.bouncy) {
                hideLeftButton = true
            }
        }

        buttonState = .loading

        do {
            let result = try await asyncAction()
            
            switch result {
            case .success(let title):
                print("Async action success with title: \(title ?? "nil")")
                withAnimation(.easeInOut(duration: 0.4)) {
                    dynamicTitle = title
                    buttonState = .success
                    retryCount = 0
                    isInRetryMode = false
                }
                if let haptic = config.asyncConfig?.successAppearance?.hapticFeedbackOnCompletion {
                    haptic.generate()
                }
                if let action = config.asyncConfig?.actionAfterSuccess {
                    switch action {
                    case .noAction:
                        await resetAfterCompletion()
                        break
                    case .pop:
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                            BottomDrawerRouter.shared.pop()

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                                unhideLeftButtonIfNeeded()
                            })
                        })
                    case .dismiss:
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                            BottomDrawerRouter.shared.dismiss()
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                                unhideLeftButtonIfNeeded()
                            })
                        })
                    }
                }
            case .failure(let error):
                print("Async action failure with error: \(error.localizedDescription)")
                await handleAsyncFailure(error)
            }
        } catch {
            print("Async action caught error: \(error.localizedDescription)")
            await handleAsyncFailure(error)
        }
    }

    @MainActor
    private func handleAsyncFailure(_ error: Error) async {
        retryCount += 1
        print("Handling async failure. Retry count: \(retryCount)")
        if let maxRetries = config.asyncConfig?.maxRetryCount, retryCount >= maxRetries {
            print("Max retries reached: \(maxRetries)")
            if let actionAfterMax = config.asyncConfig?.actionAfterMaxRetries {
                switch actionAfterMax {
                case .noAction:
                    withAnimation(.easeInOut(duration: 0.4)) {
                        dynamicTitle = error.localizedDescription
                        buttonState = .error
                        isInRetryMode = false
                    }
                    if let haptic = config.asyncConfig?.errorAppearance?.hapticFeedbackOnCompletion {
                        haptic.generate()
                    }
                    await resetAfterCompletion()
                case .pop:
                    withAnimation(.easeInOut(duration: 0.4)) {
                        dynamicTitle = error.localizedDescription
                        buttonState = .error
                        isInRetryMode = false
                    }
                    if let haptic = config.asyncConfig?.errorAppearance?.hapticFeedbackOnCompletion {
                        haptic.generate()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        BottomDrawerRouter.shared.pop()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            unhideLeftButtonIfNeeded()
                            retryCount = 0
                        }
                    }
                case .dismiss:
                    withAnimation(.easeInOut(duration: 0.4)) {
                        dynamicTitle = error.localizedDescription
                        buttonState = .error
                        isInRetryMode = false
                    }
                    if let haptic = config.asyncConfig?.errorAppearance?.hapticFeedbackOnCompletion {
                        haptic.generate()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        BottomDrawerRouter.shared.dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            unhideLeftButtonIfNeeded()
                            retryCount = 0
                        }
                    }
                }
            } else {
                withAnimation(.easeInOut(duration: 0.4)) {
                    dynamicTitle = error.localizedDescription
                    buttonState = .error
                    isInRetryMode = false
                }
                if let haptic = config.asyncConfig?.errorAppearance?.hapticFeedbackOnCompletion {
                    haptic.generate()
                }
                await resetAfterCompletion()
            }
        } else {
            print("Entering 'Try Again' mode")
            withAnimation(.easeInOut(duration: 0.4)) {
                if let retryable = error as? RetryableError, let retryTitle = retryable.retryTitle {
                    dynamicTitle = retryTitle
                } else {
                    dynamicTitle = "Try Again"
                }
                buttonState = .error
                isInRetryMode = true
            }
            if isInRetryMode, let haptic = config.asyncConfig?.tryAgainAppearance?.hapticFeedbackOnCompletion {
                haptic.generate()
            }
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
            withAnimation(.easeInOut(duration: 0.4)) {
                buttonState = .idle
            }
            unhideLeftButtonIfNeeded()
        }
    }

    private func unhideLeftButtonIfNeeded() {
        if config.asyncConfig?.hidesLeftButtonOnTap ?? false {
            withAnimation(.bouncy) {
                hideLeftButton = false
            }
        }
    }
    
    @MainActor
    private func resetAfterCompletion() async {
        try? await Task.sleep(nanoseconds: 1_200_000_000) // 1.2 seconds

        withAnimation(.easeInOut(duration: 0.4)) {
            buttonState = .idle
            retryCount = 0
            isInRetryMode = false
        }
        
        withAnimation(.bouncy) {
            if config.asyncConfig?.hidesLeftButtonOnTap ?? false {
                hideLeftButton = false
            }
        }
    }

    private var shapeView: some Shape {
        switch config.shape {
        case .rounded(let radius):
            return AnyShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
        case .capsule:
            return AnyShape(Capsule())
        }
    }

    private func foregroundColor(for background: Color) -> Color {
        let uiColor = UIColor(background)
        var white: CGFloat = 1
        uiColor.getWhite(&white, alpha: nil)

        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 1
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        // Luminance calculation for contrast decision
        let luminance = 0.2126 * red + 0.7152 * green + 0.0722 * blue
        return luminance < 0.5 ? .white : .black
    }

    private func currentIconName(for state: DrawerButtonState) -> String? {
        withAnimation(.smooth) {
            switch state {
            case .idle:
                return config.icon
            case .loading:
                return nil
            case .success:
                return config.asyncConfig?.successAppearance?.icon
            case .error:
                if isInRetryMode {
                    return config.asyncConfig?.tryAgainAppearance?.icon ?? config.asyncConfig?.errorAppearance?.icon
                } else {
                    return config.asyncConfig?.errorAppearance?.icon
                }
            }
        }
    }

    private func currentTitle(for state: DrawerButtonState) -> String {
        withAnimation(.smooth) {
            switch state {
            case .idle:
                return config.title
            case .loading:
                return ""
            case .success:
                return dynamicTitle ?? config.asyncConfig?.successAppearance?.title ?? config.title
            case .error:
                if isInRetryMode {
                    return dynamicTitle ?? config.asyncConfig?.tryAgainAppearance?.title ?? "Try Again"
                } else {
                    return dynamicTitle ?? config.asyncConfig?.errorAppearance?.title ?? config.title
                }
            }
        }
    }

    private func backgroundColor(for state: DrawerButtonState) -> Color {
        withAnimation(.smooth) {
            switch state {
            case .idle:
                return config.backgroundColor
            case .loading:
                return config.backgroundColor
            case .success:
                return config.asyncConfig?.successAppearance?.backgroundColor ?? config.backgroundColor
            case .error:
                if isInRetryMode {
                    return config.asyncConfig?.tryAgainAppearance?.backgroundColor ?? config.asyncConfig?.errorAppearance?.backgroundColor ?? config.backgroundColor
                } else {
                    return config.asyncConfig?.errorAppearance?.backgroundColor ?? config.backgroundColor
                }
            }
        }
    }

    private func borderColor(for state: DrawerButtonState) -> Color {
        withAnimation(.smooth) {
            switch state {
            case .idle:
                return config.borderColor
            case .loading:
                return config.borderColor
            case .success:
                return config.asyncConfig?.successAppearance?.borderColor ?? config.borderColor
            case .error:
                if isInRetryMode {
                    return config.asyncConfig?.tryAgainAppearance?.borderColor ?? config.asyncConfig?.errorAppearance?.borderColor ?? config.borderColor
                } else {
                    return config.asyncConfig?.errorAppearance?.borderColor ?? config.borderColor
                }
            }
        }
    }
}
