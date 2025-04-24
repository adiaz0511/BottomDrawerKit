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
    @State private var previousConfig: DrawerButtonConfig? = nil
    @State private var isTransitioning = false

    var body: some View {
        Button(action: config.action) {
            Color.clear
                .frame(height: 54)
                .frame(maxWidth: .infinity)
                .background(
                    ZStack {
                        config.backgroundColor
                            .clipShape(shapeView)

                        ZStack {
                            if let previous = previousConfig {
                                label(for: previous)
                                    .opacity(isTransitioning ? 1 : 0)
                            }

                            label(for: config)
                                .opacity(isTransitioning ? 0 : 1)
                        }
                        .animation(.easeInOut(duration: 0.18), value: isTransitioning)
                        .padding(.horizontal)
                    }
                )
                .overlay(
                    shapeView
                        .stroke(config.borderColor, lineWidth: 2)
                )
        }
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

    @ViewBuilder
    private func label(for config: DrawerButtonConfig) -> some View {
        HStack(spacing: 8) {
            if let icon = config.icon {
                Image(systemName: icon)
            }
            Text(config.title)
        }
        .font(.headline)
        .foregroundColor(foregroundColor(for: config.backgroundColor))
        .blur(radius: isTransitioning ? 6 : 0)
        .animation(.easeInOut(duration: 0.18), value: isTransitioning)
        .contentTransition(.numericText())
    }
}
