<p align="center">
  <img src="https://github.com/user-attachments/assets/305cbe2a-b915-4924-803e-efbe0f725c76" alt="BDKAppIcon2" width="120">
</p>

<div align="center">

# BottomDrawerKit

**BottomDrawerKit** lets you present a highly customizable bottom drawer or card in SwiftUI, with smooth transitions, dynamic heights, and full route control.

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

Apply the bottomDrawer(style:) modifier to your top-level view (usually in your App entry point):

```swift
import BottomDrawerKit

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .bottomDrawer(style: .drawer) // or .card
                .bottomDrawerRouter(BottomDrawerRouter.shared)
        }
    }
}
```

> You can inject the router using .bottomDrawerRouter(...) or, alternatively, with .environment(\.bottomDrawerRouter, ...).


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

Each route defines a `Config` struct that controls behavior, layout, buttons, and appearance of the drawer or card.

```swift
Config(
    interactiveDismiss: true,
    dragHandleVisibility: .visible,
    height: .points(420),
    initialHeight: .fraction(0.4),
    maxHeight: .fraction(0.9),
        primaryButton: DrawerButtonConfig(
        title: "Save",
        icon: "checkmark",
        backgroundColor: .blue,
        borderColor: .clear,
        shape: .capsule,
        hapticFeedback: .light,
        action: { print("Saved!") }
    ),
    secondaryButton: DrawerButtonConfig(
        title: "Cancel",
        backgroundColor: .clear,
        borderColor: .primary,
        shape: .capsule,
        hapticFeedback: .light,
        action: { print("Cancelled!") }
    ),
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

### 📏 Layout & Behavior

| Property              | Description                                                                 |
|-----------------------|-----------------------------------------------------------------------------|
| `interactiveDismiss`  | Whether the drawer can be dismissed by tapping outside or swiping down      |
| `dragHandleVisibility`| Controls visibility of the top drag handle (`.visible`, `.hidden`, `.static`)|
| `height`              | Final resting height of the drawer/card                                    |
| `initialHeight`       | Initial height for animated expansion                                      |
| `maxHeight`           | Maximum allowed height                                                     |
| `onDismiss`           | Closure triggered when the drawer is dismissed (sync)                      |
| `onDismissAsync`      | Async closure triggered when the drawer is dismissed (for async work)       |

### 🔘 Buttons

Each button uses a `DrawerButtonConfig`:

| Config Field       | Description                                                   |
|--------------------|---------------------------------------------------------------|
| `title`            | Button label text                                             |
| `icon`             | Optional SF Symbol (e.g., `"trash"`, `"checkmark"`)           |
| `backgroundColor`  | Fill color of the button                                      |
| `borderColor`      | Optional stroke color                                         |
| `shape`            | Button shape (`.capsule` or `.rounded(cornerRadius)`)         |
| `hapticFeedback`   | Optional haptic feedback triggered on tap (`.light`, `.medium`, `.heavy`) |
| `action`           | Closure triggered when the button is tapped (sync action)     |
| `asyncConfig`      | Configure an async action, loading indicators, retry behavior, and success/error states |

If you want to perform **asynchronous actions**, use the `asyncConfig` property:

| Async Config Field           | Description |
|-------------------------------|-------------|
| `asyncAction`                 | Async closure to perform when the button is tapped. Should return `Result<String?, Error>`. The `String?` is used to update the button title dynamically on success. |
| `hidesLeftButtonOnTap`        | If `true`, the secondary button hides during async action for a cleaner loading experience. |
| `errorAppearance`             | Optional appearance (`icon`, `backgroundColor`, etc.) to apply when the async action fails. |
| `tryAgainAppearance`          | Optional appearance for the "Try Again" state after a failure. If omitted, a default retry appearance is used. |
| `successAppearance`           | Optional appearance to apply when the async action succeeds. |
| `actionAfterSuccess`          | What happens after success (`.noAction`, `.pop`, or `.dismiss`). |
| `maxRetryCount`               | Maximum number of retry attempts allowed after failure. If exceeded, a fallback action will be triggered. |
| `actionAfterMaxRetries`       | What happens after reaching `maxRetryCount` (`.noAction`, `.pop`, or `.dismiss`). |

When setting `successAppearance`, `errorAppearance`, or `tryAgainAppearance`, you can configure:

| Field                          | Description |
|---------------------------------|-------------|
| `icon`                         | SF Symbol to display for that result state |
| `backgroundColor`              | Background color of the button during that state |
| `borderColor`                  | Optional border color for that state |
| `title`                        | Optional title override for that state |
| `hapticFeedbackOnCompletion`   | Optional haptic feedback to trigger when this state occurs (`.light`, `.medium`, `.heavy`, `.success`, `.warning`, `.error`) |

✅ You can leave any field `nil` to fallback to default behaviors.

**Special Note:**  
If the `Error` thrown from the asyncAction conforms to `RetryableError`,  
you can provide a custom `retryTitle` to dynamically update the "Try Again" button text based on the failure.

```swift
protocol RetryableError: Error {
    var retryTitle: String? { get }
}
```

---

## 🧠 Advanced: Dynamically Enable/Disable Buttons

BottomDrawerKit allows you to **dynamically control** the enabled/disabled state of the primary and secondary buttons from anywhere inside your presented view.

To enable this feature, you must inject a `DrawerButtonContext` into your environment.

Example in your `App` entry point:

```swift
@main
struct BottomDrawerKitExampleApp: App {
    let buttonContext: DrawerButtonContext = .init()
    
    var body: some Scene {
        WindowGroup {
            ContentView(style: $style)
                .bottomDrawer(style: style)
                .environment(\.bottomDrawerRouter, BottomDrawerRouter.shared)
                .environment(\.drawerButtonContext, buttonContext)
        }
    }
}
```

Or use the following view modifier for cleaner injection:

```swift
.drawerButtonContext(buttonContext)
```


Inside any view presented by the drawer or card, you can then access the context:

```swift
@Environment(\.drawerButtonContext) private var buttonContext
```

And dynamically enable or disable either button:

```swift
buttonContext?.isPrimaryButtonEnabled = false
buttonContext?.isSecondaryButtonEnabled = true
```

✅ If no DrawerButtonContext is provided, buttons will behave normally and stay enabled by default.

✅ This is optional and only needed if you want runtime control over the buttons’ enabled states.

---

### 🎨 Visual Style (for `.card` only)

| Property                 | Description                                                                 |
|---------------------------|-----------------------------------------------------------------------------|
| `background`              | Any `ShapeStyle` (e.g., `Color`, `Material`) used as the drawer/card fill   |
| `borderColor`             | Optional border color (used only in `.card`)                               |
| `shadow`                  | Optional shadow (color, radius, offset) for `.card` appearance             |
| `drawerStyleOverride`     | Optional `DrawerStyle` to override global corner radius and padding **for this specific route** |

✅ `drawerStyleOverride` allows you to locally override the card's **corner radius** and **horizontal padding**, instead of using the global environment setting.

✅ This is **only used** for `.card` style — drawers ignore this for consistency with system sheets.

✅ It enables advanced behaviors like:
- Creating **sheet-like** cards (flat top, full-width)
- Creating **full-screen cards** with smooth safe area adjustment
- Preventing clipping on rounded corners when content fills the screen

If `drawerStyleOverride` is set:
- It will automatically account for safe area insets
- It prevents corner radius artifacts when reaching full device height

Example:

```swift
Config(
    height: .fraction(1.0),
    initialHeight: .fraction(1.0),
    maxHeight: .fraction(1.0),
    visualStyle: VisualStyle(
        background: AnyShapeStyle(.white),
        drawerStyleOverride: DrawerStyle(
            cornerRadius: .fixed(0),
            padding: 0
        )
    )
)
```

> **Note:** In `.drawer` style, only the `background` is used. `borderColor` and `shadow` are ignored for consistency with system-like sheets.

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

Or use the dedicated view modifier:

```swift
.bottomDrawerStyle(DrawerStyle(
    cornerRadius: .device,
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

## 🤝 Contributing

Interested in contributing?  
Please read the [CONTRIBUTING.md](./CONTRIBUTING.md) guide for instructions and guidelines.  
Thank you for helping make BottomDrawerKit even better! 🚀

---

## Support
If you like this project, please consider giving it a ⭐️

---

## License

BottomDrawerKit is licensed under the [Apache License 2.0](LICENSE).
