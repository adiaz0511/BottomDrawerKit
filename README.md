<p align="center">
  <img src="https://github.com/user-attachments/assets/305cbe2a-b915-4924-803e-efbe0f725c76" alt="BDKAppIcon2" width="120">
</p>

<div align="center">

# BottomDrawerKit

[![Swift Package](https://img.shields.io/badge/Swift_Package-Compatible-brightgreen)](...)
[![Swift Version](https://img.shields.io/badge/swift-6.0-orange.svg)](...)
[![Xcode](https://img.shields.io/badge/Xcode-16.3-blue)](...)
[![iOS](https://img.shields.io/badge/iOS-18%2B-blue)](...)
[![Platforms](https://img.shields.io/badge/platforms-iOS-lightgrey.svg)](...)

[![Version](https://img.shields.io/github/v/tag/adiaz0511/BottomDrawerKit)](https://github.com/adiaz0511/BottomDrawerKit/releases)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)

[![Stars](https://img.shields.io/github/stars/adiaz0511/BottomDrawerKit.svg?style=social)](...)
[![Forks](https://img.shields.io/github/forks/adiaz0511/BottomDrawerKit.svg?style=social)](...)
[![Watchers](https://img.shields.io/github/watchers/adiaz0511/BottomDrawerKit.svg?style=social)](...)

**BottomDrawerKit** lets you present a highly customizable bottom drawer or card in SwiftUI, with smooth transitions, dynamic heights, and full route control.

</div>


<div align="center">

| Drawer | Card |
|--------|------|
| ![DrawerRec2](https://github.com/user-attachments/assets/bea6c4af-0b20-48db-8761-ffa83c73aba8) | ![CardRec2](https://github.com/user-attachments/assets/860ec181-7657-4598-b089-e4c2a8a13a6b)|

</div>

---

## 📦 Installation

### Swift Package Manager

Add this to your `Package.swift`:

```swift
.package(url: "https://github.com/adiaz0511/BottomDrawerKit.git", from: "1.0.0")
```

Then add `"BottomDrawerKit"` as a dependency to your target.

Or add it in Xcode:

> File → Add Packages… → Enter repo URL → Add `BottomDrawerKit`

---

## 📱 Example App

This repo includes a demo app under `/Example` that shows BottomDrawerKit in action.

To try it out:
1. Open `Example/BottomDrawerKitExampleApp.xcodeproj`
2. Run the app on Simulator

---

## ✅ 1. Add `.bottomDrawer()` to your root view

Apply the `bottomDrawer(style:)` modifier to your top-level view (usually in your `App` entry point):

```swift
import BottomDrawerKit

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.bottomDrawerRouter, BottomDrawerRouter.shared)
                .bottomDrawer(style: .drawer) // or .card
        }
    }
}
```

---

## ✅ 2. Define your routes

Create your own route type conforming to `BottomDrawerRouteable`. Most commonly, you'll use an enum:

```swift
enum MyDrawerRoute: BottomDrawerRouteable {
    case settings, profile

    var config: Config {
        Config(height: .fraction(0.5))
    }

    @ViewBuilder
    func view() -> some View {
        switch self {
        case .settings: SettingsView()
        case .profile: ProfileView()
        }
    }

    var id: String { String(describing: self) }
}
```

> Prefer enums for clear navigation structure, but you can also use dynamic structs if needed (see below).

---

## ✅ 3. Present a route

Use the router via the SwiftUI environment:

```swift
@Environment(\.bottomDrawerRouter) var router

Button("Show Settings") {
    router.presentRoute(MyDrawerRoute.settings)
}
```

You can also use **global static access**:

```swift
Task {
    await BottomDrawerRouter.present(MyDrawerRoute.settings)
}
```

> Static methods like `.present(...)`, `.pop()`, etc., are `@MainActor`. You must call them inside a `Task` if you're in a synchronous context (e.g. a `Button` action).

> This is enabled by default via static forwarding methods like `.present()`, `.dismiss()`, etc.

---

## ✅ 4. Dismiss or navigate

You can control navigation using either the **environment-injected instance** or the **global static methods** — depending on your use case.

If you've injected the router with:

```swift
.environment(\.bottomDrawerRouter, BottomDrawerRouter.shared)
```

you can access it in your views like this:

```swift
@Environment(\.bottomDrawerRouter) var router

Button("Show Settings") {
    router.presentRoute(MyDrawerRoute.settings)
}

Button("Back") {
    router.popRoute()
}

Button("Back to Root") {
    router.popToRootRoute()
}

Button("Dismiss") {
    router.dismissRoutes()
}
```

✅ These instance methods (`presentRoute`, `popRoute`, `popToRootRoute`, `dismissRoute`) are safe to call directly — no need to wrap them in Task.

If you prefer using the **static access methods**:

```swift
Task {
    await BottomDrawerRouter.present(MyDrawerRoute.settings)
}

Task {
    await BottomDrawerRouter.pop()
}

Task {
    await BottomDrawerRouter.popToRoot()
}

BottomDrawerRouter.dismiss()
```

⚠️ Static methods like .present(...), .pop(), and .popToRoot() are @MainActor, so they must be called inside a Task when used from synchronous contexts like a Button action.

---

## 🔄 Dynamic routes (struct-based)

If your view is built dynamically (e.g., based on an API), you don’t need to hardcode enum cases. Just conform to the protocol directly:

```swift
struct CustomDrawerRoute: BottomDrawerRouteable {
    let id = UUID()
    let config: Config
    let content: () -> any View

    @ViewBuilder
    func view() -> some View { content() }
}
```

And use it like this:

```swift
let route = CustomDrawerRoute(
    config: .init(height: .points(320)),
    content: { Text("Dynamic Drawer View") }
)

BottomDrawerRouter.present(route)
```

---

## 🛠 Configuration Options

Each route can define:

```swift
Config(
    interactiveDismiss: true,
    dragHandleVisibility: .visible,
    height: .points(420),
    initialHeight: .fraction(0.4),
    maxHeight: .fraction(0.9),
    visualStyle: VisualStyle(
        background: AnyShapeStyle(Color.black),
        borderColor: .secondary,
        shadow: VisualStyle.Shadow(
            color: .black.opacity(0.1),
            radius: 8,
            offset: CGSize(width: 0, height: 2)
        )
    ),
    onDismiss: { print("Closed!") },
    onDismissAsync: { await fetch() }
)
```

---

## 💅 Styling

Use `.drawer` or `.card` in `.bottomDrawer(style:)`.

- `.card` feels like a panel or floating card. It supports full styling via `VisualStyle`.
- `.drawer` behaves like a system sheet. You can override its **background** via `VisualStyle`, but other styles (border, shadow, etc.) are ignored to maintain consistency.

---

### 🔹 DrawerStyle (global, for `.card` only)

Globally configure corner radius and padding via `DrawerStyle`:

```swift
.environment(\.drawerStyle, DrawerStyle(
    cornerRadius: .device, // or .fixed(20)
    padding: 16
))
```

---

### 🔹 VisualStyle (local, per-route)

Configure per-route appearance via `visualStyle` in `Config`:

- `background`: supports `.fill(...)` with color/material
- `borderColor`: optional (used only in `.card`)
- `shadow`: optional (used only in `.card`)

**Note:** All drawers and cards share the same layout system. In `.drawer`, only the background is applied.

---

⚠️ **Important:**

If you're using the `.drawer` style, it's *strongly recommended* that you set `.height`, `.initialHeight`, and `.maxHeight` in your `Config`.

This allows the drawer to know how much space to reserve and animate properly.

```swift
Config(
 height: .fraction(0.4),
 initialHeight: .fraction(0.3),
 maxHeight: .points(300)
)
```

If you’re using `.card`, you still need to provide height values, but they won’t be used — the card will automatically adjust to fit its content.

---

## 🧪 Testing / Previewing

In previews, inject the router manually:

```swift
#Preview {
    ContentView()
        .environment(\.bottomDrawerRouter, BottomDrawerRouter.shared)
        .bottomDrawer(style: .drawer)
}
```

---

## License

BottomDrawerKit is licensed under the [Apache License 2.0](LICENSE).
