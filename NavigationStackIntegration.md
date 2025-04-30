# 📚 Coordinating BottomDrawerKit with NavigationStack

Sometimes you’ll want to control your app’s `NavigationStack` from inside a bottom drawer — for example, to dismiss a view after an action like deletion.

SwiftUI doesn’t provide a direct way to `pop()` a navigation stack programmatically. Instead, you can expose and control the navigation path using an observable object.

---

## ✅ 1. Create a NavigationPathManager

```swift
import SwiftUI
import Observation

@Observable
public final class NavigationPathManager {
    public var path: [AnyHashable] = []

    public func pop() {
        _ = path.popLast()
    }

    public func popToRoot() {
        path.removeAll()
    }
}
```

## ✅ 2. Use it in your App or Scene

```swift
@main
struct MyApp: App {
    @State private var pathManager = NavigationPathManager()

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $pathManager.path) {
                ContentView()
            }
            .environment(\.navigationPathManager, pathManager)
            .bottomDrawer(style: .drawer)
            .injectBottomDrawerRouter()
        }
    }
```

## ✅ 3. Add environment support

```swift
private struct NavigationPathManagerKey: EnvironmentKey {
    static let defaultValue: NavigationPathManager? = nil
}

public extension EnvironmentValues {
    var navigationPathManager: NavigationPathManager? {
        get { self[NavigationPathManagerKey.self] }
        set { self[NavigationPathManagerKey.self] = newValue }
    }
}

public extension View {
    func navigationPathManager(_ manager: NavigationPathManager) -> some View {
        environment(\.navigationPathManager, manager)
    }
}
```

## ✅ 4. Use it from inside a drawer or route

```swift
@Environment(\.navigationPathManager) var nav

Button("Delete") {
    nav?.pop()
    BottomDrawerRouter.dismiss()
}
```

or 

```swift
nav?.popToRoot()
BottomDrawerRouter.dismiss()
```

---

This lets your drawer coordinate with the main navigation stack cleanly and declaratively.

🧠 Note: This is not specific to BottomDrawerKit — it’s a general SwiftUI pattern for NavigationStack management.
