//
//  ContentView.swift
//  BottomDrawerKitExample
//
//  Created by Arturo Diaz on 4/23/25.
//

import SwiftUI
import BottomDrawerKit

struct ContentView: View {
    @Environment(\.bottomDrawerRouter) var router
    @Binding var style: BottomDrawerStyle
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            Image(.bottomDrawerKitIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .rotationEffect(.degrees(-20), anchor: .center)
            
            VStack(alignment: .center, spacing: 14) {
                Text("BottomDrawerKit Demo")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.black)
                
                Text("A demo of BottomDrawerKit in action—showcasing styles, customization, and seamless SwiftUI integration.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.bottom, 100)
            
            HStack(spacing: 16) {
                StyleToggleButton(image: .drawerLayout, title: "Drawer", isSelected: style == .drawer) {
                    withAnimation(.spring) {
                        style = .drawer
                    }
                }
                StyleToggleButton(image: .cardLayout, title: "Card", isSelected: style == .card) {
                    withAnimation(.spring) {
                        style = .card
                    }
                }
            }
            
            Button {
                withAnimation(.spring) {
                    router.presentRoute(BottomDrawerDemoRoute.actionButtons)
                }
            } label: {
                Label("Show", systemImage: "dock.arrow.up.rectangle")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.gradient)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color.blue.opacity(0.3), radius: 5, y: 2)
            }
            .padding(.top)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(
            Color.white
                .edgesIgnoringSafeArea(.all)
        )
        .preferredColorScheme(.light)
    }
}

struct StyleToggleButton: View {
    let image: ImageResource
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    let gradient1 = [Color.primary, Color.primary.opacity(0.1)]
    let gradient2 = [Color(.button), Color(.button).opacity(0.1)]
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .center, spacing: 16) {
                Image(image)
                    .resizable()
                    .scaledToFit()
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 16,
                            bottomLeadingRadius: 0,
                            bottomTrailingRadius: 0,
                            topTrailingRadius: 16,
                            style: .continuous
                        )
                    )
                    .overlay(
                        alignment: .top) {
                            LinearGradient(colors: isSelected ? gradient1 : gradient2, startPoint: .top, endPoint: .center)
                        }

                Text(title)
                    .padding([.bottom, .horizontal])
            }
            .frame(maxWidth: .infinity)
            .background(
                Group {
                    if isSelected {
                        Color.primary
                    } else {
                        Color(Color(.button))
                    }
                }
            )
            .foregroundColor(isSelected ? Color(colorScheme == .dark ? .black : .white) : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                Group {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.primary, lineWidth: 1.5)
                            .padding(-5)
                    }
                }
            )
        }
        
    }
}

struct ActionButtonsView: View {
    @Bindable var router = BottomDrawerRouter.shared
    
    var body: some View {
        VStack(spacing: 16) {
            // Top two buttons
            HStack(spacing: 16) {
                Button(action: {
                    router.presentRoute(BottomDrawerDemoRoute.colorScheme)
                }) {
                    ActionButton(icon: "lightbulb.fill", text: "Color Scheme", color: .white)
                }
                
                Button(action: {
                    router.presentRoute(BottomDrawerDemoRoute.nameInput)
                }) {
                    ActionButton(icon: "person.fill", text: "Name", color: .orange)
                }
            }
            
            // Middle buttons
            HStack(spacing: 16) {
                Button(action: {
                    router.presentRoute(BottomDrawerDemoRoute.colorPicker)
                }) {
                    ActionButton(icon: "swatchpalette.fill", text: "Theme", color: .blue)
                }
                
                Button(action: {
                    router.presentRoute(BottomDrawerDemoRoute.showCard)
                }) {
                    ActionButton(icon: "movieclapper", text: "TV Show", color: .red)
                }
            }
            
        }
        .padding()
    }
}

struct ActionButton: View {
    let icon: String
    let text: String
    let color: Color
    var fullWidth: Bool = false
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(text)
                .foregroundColor(.white)
        }
        .font(.subheadline)
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            Color(hex: "48484a")
                .clipShape(RoundedRectangle(cornerRadius: 12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
        )
    }
}

struct NameInputView: View {
    @State private var name: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("What's your name?")
                .font(.headline)
                .foregroundColor(.white)
            
            TextField("", text: $name)
                .textFieldStyle(.plain)
                .foregroundColor(.white)
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.white)
                        .offset(y: 10),
                    alignment: .bottom
                )
        }
        .padding()
        .padding(.bottom, 20)
    }
}

#Preview {
    ContentView(style: .constant(.drawer))
}

struct ViewPreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

struct ShowCardView: View {
    @Bindable var router = BottomDrawerRouter.shared
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Shrinking")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                        .padding([.horizontal])
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    Text("Apple TV+ · 2023")
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding([.horizontal, .bottom])
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    ScrollView {
                        HStack(spacing: 10) {
                            Label("Returning Series", systemImage: "arrow.2.squarepath")
                                .labelStyle(.titleAndIcon)
                                .padding(8)
                                .background(
                                    Capsule()
                                        .fill(Color(hex: "48484a"))
                                        .overlay(
                                            Capsule()
                                                .stroke(.white, lineWidth: 0.2)
                                        )
                                )
                            
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text("7.8")
                                    .foregroundColor(.white)
                            }
                            .padding(8)
                            .background(
                                Capsule()
                                    .fill(Color(hex: "48484a"))
                                    .overlay(
                                        Capsule()
                                            .stroke(.white, lineWidth: 0.2)
                                    )
                            )
                            
                            Spacer()
                            
                            Button {
                                router.popRoute()
                            } label: {
                                Label("Back", systemImage: "arrow.uturn.backward")
                                    .padding(12)
                                    .background(Color.white.gradient)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color(hex: "#fefefe"), lineWidth: 2)
                                    )
                            }
                            .foregroundColor(.black)
                        }
                        .foregroundColor(.white.opacity(0.9))
                        .font(.subheadline)
                        .padding(.horizontal)
                        .padding(.top, 20)
                        
                        HStack(spacing: 10) {
                            Text("TV-MA")
                                .padding(8)
                                .background(
                                    Capsule()
                                        .fill(Color(hex: "48484a"))
                                        .overlay(
                                            Capsule()
                                                .stroke(.white, lineWidth: 0.2)
                                        )
                                )
                            
                            Text("2 Seasons")
                                .padding(8)
                                .background(
                                    Capsule()
                                        .fill(Color(hex: "48484a"))
                                        .overlay(
                                            Capsule()
                                                .stroke(.white, lineWidth: 0.2)
                                        )
                                )
                        }
                        .foregroundColor(.white.opacity(0.9))
                        .font(.subheadline)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Summary")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("Jimmy is struggling to grieve the loss of his wife while being a dad, friend, and therapist. He decides to try a new approach with everyone in his path: unfiltered, brutal honesty.")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.9))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.top)
                        .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Cast")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 20) {
                                    castMember(name: "Alex Stone", role: "Dr. Eli")
                                    castMember(name: "Jamie Cruz", role: "Ava")
                                    castMember(name: "Reed Moore", role: "Michael")
                                }
                            }
                        }
                        .contentMargins(.horizontal, 16)
                        .padding(.top)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Crew")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 20) {
                                    castMember(name: "Alex Stone", role: "Dr. Eli")
                                    castMember(name: "Jamie Cruz", role: "Ava")
                                    castMember(name: "Reed Moore", role: "Michael")
                                }
                            }
                        }
                        .contentMargins(.horizontal, 16)
                        .padding(.top)
                    }
                    .frame(minHeight: 600)
                    .scrollIndicators(.hidden)
                }
            }
        }
        .padding(.top, 20)
        .frame(maxHeight: UIScreen.main.bounds.height - 200)
    }
    
    func castMember(name: String, role: String) -> some View {
        VStack {
            Image(systemName: "person.circle")
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .foregroundColor(.white.opacity(0.8))
            Text(name)
                .font(.caption)
                .foregroundColor(.white)
            Text(role)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.6))
        }
    }
}

struct ColorPickerView: View {
    @Bindable var router = BottomDrawerRouter.shared
    @State private var selectedColor: Color? = nil
    
    let colors: [Color] = [
        Color(hex: "#FF3B30"), // Red
        Color(hex: "#FF5E3A"), // Reddish Orange
        Color(hex: "#FF9500"), // Orange
        Color(hex: "#FFCC00"), // Amber Yellow
        Color(hex: "#FFE600"), // Yellow
        Color(hex: "#D1F400"), // Lime
        Color(hex: "#A4E400"), // Yellow-Green
        Color(hex: "#34C759"), // Green
        Color(hex: "#30D158"), // Fresh Green
        Color(hex: "#00C7BE"), // Teal
        Color(hex: "#32ADE6"), // Sky Blue
        Color(hex: "#0A84FF"), // Blue
        Color(hex: "#5AC8FA"), // Light Blue
        Color(hex: "#5856D6"), // Indigo
        Color(hex: "#AF52DE"), // Violet
        Color(hex: "#BF5AF2"), // Light Purple
        Color(hex: "#FF2D55"), // Pink
        Color(hex: "#FF375F"), // Hot Pink
        Color(hex: "#FF4981"), // Soft Magenta
        Color(hex: "#C644FC")  // Deep Purple
    ]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            VStack(alignment: .center, spacing: 4) {
                Text("Select a Color")
                    .font(.title2.bold())
                    .padding(.top, 10)
                    .foregroundStyle(.white)
                
                Text("This color will be applied to the entire app")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.bottom, 10)
            
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(colors, id: \.self) { color in
                    Button {
                        selectedColor = color
                    } label: {
                        Circle()
                            .fill(color)
                            .frame(width: 50, height: 50)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: selectedColor == color ? 3 : 0)
                                    .padding(-3)
                                
                            )
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
        .padding(.top, 20)
    }
}

#Preview {
    ShowCardView()
}


struct DeleteOptionView: View {
    var title: String
    var subtitle: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.subheadline)
                .foregroundStyle(.white)
                .padding(12)
                .background(Color.white.opacity(0.5))
                .clipShape(Circle())
            
            Text(title)
                .font(.title2.bold())
                .foregroundColor(.white)
            
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

struct ColorSchemeView: View {
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 4) {
                Text("Color Scheme")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                
                Text("Choose a color scheme for the app")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
            }
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            
            HStack(spacing: 16) {
                SchemeButton(title: "System", icon: "circle.lefthalf.filled")
                SchemeButton(title: "Light", icon: "sun.max.fill")
                SchemeButton(title: "Dark", icon: "moon.fill")
            }
        }
        .padding(.vertical, 24)
        .padding(.horizontal)
    }
    
    struct SchemeButton: View {
        let title: String
        let icon: String
        
        var body: some View {
            Button(action:{}) {
                VStack(spacing: 6) {
                    Image(systemName: icon)
                        .font(.title3)
                    
                    Text(title)
                        .font(.callout)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(hex: "48484a"))
                .clipShape(RoundedRectangle(cornerRadius: 20))
            }
        }
    }
}


extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17,
                            (int >> 4 & 0xF) * 17,
                            (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24,
                            int >> 16 & 0xFF,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(.sRGB,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}
