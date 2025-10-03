# Zero State Pre-warming Investigation

**Status**: Not Working
**Date**: October 1, 2025
**Issue**: Zero-state suggestions are not being fetched at app startup; they only fetch when the window is first opened, causing shimmer/loading state.

---

## Problem Statement

### Expected Behavior

1. App launches
2. Within 1-2 seconds, ViewModel initializes in background
3. Zero-state suggestions fetched from backend (4 fresh AI-generated items)
4. Suggestions cached in memory
5. User presses hotkey 10-30 seconds later
6. Window opens → zero state shows instantly from cache (no shimmer)

### Actual Behavior

1. App launches
2. **Nothing happens** (no ViewModel initialization)
3. User presses hotkey
4. Window opens
5. **Now** ViewModel initializes (28ms before window opens)
6. Zero-state fetch starts
7. Shimmer shows while waiting for backend response

### Evidence from Logs

```
2025-10-01 13:14:07.993  🧠 ViewModel initialized - pre-warming zero state
2025-10-01 13:14:08.021  🪟 Opening window        ← Only 28ms later!
2025-10-01 13:14:08.042  🔥 Starting zero-state pre-warm
```

**Missing logs**: We never see `🚀 App launched` or `🎮 Initializing controller` in the logs, suggesting AppDelegate and FamiliarWindowController never initialize.

---

## Architecture Overview

### Component Chain

```
App.swift
  └─> @NSApplicationDelegateAdaptor(AppDelegate.self)
      └─> AppDelegate.applicationDidFinishLaunching()
          └─> FamiliarWindowController.shared ← Access singleton
              └─> FamiliarWindowController.init()
                  └─> NSHostingController(rootView: FamiliarView())
                      └─> @StateObject viewModel = FamiliarViewModel()
                          └─> FamiliarViewModel.init()
                              └─> Task { await prewarmZeroState() }
                                  └─> fetchZeroStateSuggestions()
                                      └─> Backend API call
```

### Current Implementation

**AppDelegate.swift** (Created to force initialization):

```swift
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        logger.info("🚀 App launched - forcing controller initialization")
        let _ = FamiliarWindowController.shared
        logger.info("✅ Controller initialized at startup")
    }
}
```

**FamiliarWindowController.init()** (Creates hosting controller eagerly):

```swift
private override init() {
    logger.info("🎮 Initializing controller")
    self.hostingController = NSHostingController(rootView: FamiliarView())
    logger.info("🎮 Hosting controller created")
    super.init()
}
```

**FamiliarViewModel.init()** (Starts pre-warming):

```swift
init() {
    logger.info("🧠 ViewModel initialized - pre-warming zero state")
    Task {
        await prewarmZeroState()
    }
}
```

---

## What We've Tried

### Attempt 1: @StateObject in App.swift

**Approach**: Declared `@StateObject controller = FamiliarWindowController.shared` in App body

**Reason**: Thought SwiftUI would initialize it when App creates

**Result**: Failed - SwiftUI's @StateObject is lazy; doesn't create until property is accessed in body

---

### Attempt 2: Force .shared Access in App.init()

**Approach**: Added `_ = FamiliarWindowController.shared` to App.init()

**Code**:

```swift
init() {
    _ = FamiliarWindowController.shared
    print("Initialized at startup")
}
```

**Result**: Failed - init() runs during struct creation, but MenuBarExtra body doesn't render until menu is clicked, so property wrappers don't evaluate

---

### Attempt 3: Make hostingController Non-Lazy

**Approach**: Changed from `lazy var` to `let`, initialize in init()

**Code**:

```swift
private let hostingController: NSHostingController<FamiliarView>

private override init() {
    self.hostingController = NSHostingController(rootView: FamiliarView())
    super.init()
}
```

**Result**: Partial success - Controller creates eagerly when accessed, but nothing was accessing it at startup

---

### Attempt 4: Use controller Property in MenuBarExtra

**Approach**: Changed `FamiliarWindowController.shared.toggle()` to `controller.toggle()` to force property use

**Result**: Failed - MenuBarExtra body still doesn't render until clicked

---

### Attempt 5: AppDelegate with applicationDidFinishLaunching

**Approach**: Use proper macOS lifecycle hook instead of SwiftUI init()

**Code**:

```swift
@NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        let _ = FamiliarWindowController.shared
    }
}
```

**Result**: Failed - Logs show AppDelegate.applicationDidFinishLaunching never fires (missing `🚀` log)

---

### Attempt 6: Add Comprehensive Logging

**Approach**: Added Logger throughout initialization chain to trace execution

**Result**: Revealed that **no** initialization happens until window toggle - AppDelegate logs never appear

---

### Attempt 7: Start Log Viewer Before App

**Approach**: Modified restart script to launch log viewer 1 second before app

**Result**: Logs now capture from beginning, but still show initialization only happens at window toggle

---

## Top 5 Reasons Why This Hasn't Worked

### 1. AppDelegate Never Actually Registers ⚠️ **MOST LIKELY**

**Problem**: `@NSApplicationDelegateAdaptor` might not work with MenuBarExtra-only apps

**Evidence**:

- AppDelegate logs (`🚀 App launched`) never appear
- `applicationDidFinishLaunching` never fires
- MenuBarExtra apps don't have a traditional NSApplicationDelegate lifecycle

**Mitigation**:

```swift
// Option A: Use @main with NSApplicationMain directly
@main
class FamiliarApp: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Force initialization here
        _ = FamiliarWindowController.shared

        // Then create SwiftUI scene
        let menu = MenuBarExtra(...)
        // ...
    }
}

// Option B: Create window/controller in main.swift before SwiftUI starts
// main.swift
let controller = FamiliarWindowController.shared  // Force create
FamiliarAppMain.main()
```

---

### 2. Singleton Pattern with SwiftUI State Conflict

**Problem**: `static let shared = FamiliarWindowController()` creates instance, but SwiftUI's `@StateObject` wrapper might be preventing proper initialization timing

**Evidence**:

- @StateObject is designed for SwiftUI-managed lifecycle
- We're mixing singleton pattern with SwiftUI state management
- Logs show initialization happens when SwiftUI needs it, not when we access .shared

**Mitigation**:

```swift
// Remove @StateObject, use singleton only
struct FamiliarAppMain: App {
    // Don't wrap in @StateObject
    private let controller = FamiliarWindowController.shared

    init() {
        // Force initialization immediately
        _ = controller
    }
}
```

---

### 3. NSHostingController Creation Deferred by SwiftUI

**Problem**: Even though we create `NSHostingController(rootView: FamiliarView())` eagerly, SwiftUI might defer actual view creation until it's needed for rendering

**Evidence**:

- ViewModel logs appear right before window opens
- Only 28ms gap between initialization and window open
- Suggests SwiftUI is optimizing away early view creation

**Mitigation**:

```swift
// Force view to actually materialize
private override init() {
    self.hostingController = NSHostingController(rootView: FamiliarView())

    // Force SwiftUI to materialize the view hierarchy
    _ = hostingController.view  // Access the underlying NSView

    super.init()
}
```

---

### 4. Log Stream Not Capturing Early Boot Logs

**Problem**: `log stream` command might not capture logs that happen in the first 1-2 seconds after app launch

**Evidence**:

- We only see logs from 13:14:07.993 onwards
- Missing expected AppDelegate logs
- Even with 1-second delay, might miss early events

**Mitigation**:

```bash
# Option A: Use Console.app instead (captures all logs retroactively)
open -a Console

# Option B: Add even more delay before app launch
sleep 3

# Option C: Write to file immediately at startup
Logger.init(...).log("STARTUP MARKER")
```

---

### 5. Task Async Context Not Running Until Main RunLoop Active

**Problem**: The `Task { await prewarmZeroState() }` might not actually run until the main run loop is fully active, which doesn't happen until UI renders

**Evidence**:

- Task fires right before window opens (when run loop becomes active for UI)
- Pre-warming starts at 13:14:08.042, right after window open request

**Mitigation**:

```swift
// Use MainActor.run with higher priority
init() {
    logger.info("🧠 ViewModel initialized - pre-warming zero state")

    // Instead of Task:
    DispatchQueue.main.async {
        Task {
            await self.prewarmZeroState()
        }
    }

    // OR: Use unstructured task with detached context
    Task.detached(priority: .high) {
        await self.prewarmZeroState()
    }
}
```

---

## Recommended Next Steps (Prioritized)

### Priority 1: Verify AppDelegate Actually Runs

**Test**: Add side effects that we can observe externally

```swift
func applicationDidFinishLaunching(_ notification: Notification) {
    // Write to file system (can't be optimized away)
    let marker = "/tmp/familiar-app-started-\(Date().timeIntervalSince1970).txt"
    try? "Started".write(toFile: marker, atomically: true, encoding: .utf8)

    logger.info("🚀 App launched")
    _ = FamiliarWindowController.shared
    logger.info("✅ Controller initialized")
}
```

Then check: `ls -la /tmp/familiar-app-started-*` to see if file was created at app startup.

---

### Priority 2: Force View Materialization

**Test**: Access the underlying NSView to force SwiftUI to build the view hierarchy

```swift
private override init() {
    logger.info("🎮 Initializing controller")
    self.hostingController = NSHostingController(rootView: FamiliarView())

    // Force view to materialize
    logger.info("🎮 Forcing view materialization")
    _ = hostingController.view.frame

    logger.info("🎮 Hosting controller created")
    super.init()
}
```

---

### Priority 3: Use Console.app to Capture ALL Logs

**Action**: Open Console.app before running restart script

1. Open Console.app
2. Filter for "process:FamiliarApp"
3. Run restart script
4. Check if AppDelegate logs appear in Console.app retroactively

---

### Priority 4: Move to Traditional AppDelegate Pattern

**Approach**: Don't use SwiftUI App lifecycle at all for menu bar app

```swift
// Remove @main from FamiliarAppMain
// Create main.swift:

import AppKit

let app = NSApplication.shared
let delegate = FamiliarAppDelegate()
app.delegate = delegate
app.run()
```

---

### Priority 5: Bypass SwiftUI State Management Entirely

**Approach**: Create controller before SwiftUI even starts

```swift
// In main.swift or App.init():
let globalController = FamiliarWindowController.shared  // Created eagerly

@main
struct FamiliarAppMain: App {
    private let controller = globalController  // Reference existing instance

    var body: some Scene {
        MenuBarExtra(...) {
            Button("Toggle") {
                globalController.toggle()  // Use global, not SwiftUI-managed
            }
        }
    }
}
```

---

## Technical Constraints

### SwiftUI MenuBarExtra Limitations

- MenuBarExtra doesn't have traditional window lifecycle hooks
- Body doesn't render until menu is clicked
- @StateObject initialization is deferred until body needs the value
- No guaranteed "app did finish launching" equivalent in pure SwiftUI

### macOS Unified Logging Timing

- `log stream` might miss logs from first 1-2 seconds
- Logs written before log stream connects are lost
- Console.app stores logs retroactively but requires manual checking

### Swift Concurrency + Main Thread

- Task { } requires active RunLoop to schedule work
- RunLoop might not be fully active until UI rendering starts
- Async work can be deferred by system until "needed"

---

## Questions to Answer

1. **Does AppDelegate.applicationDidFinishLaunching actually run?**
   - Test with filesystem side effect
   - Check Console.app for retroactive logs

2. **Is the singleton created at startup or on-demand?**
   - Add static initializer logging
   - Check if `FamiliarWindowController()` runs early

3. **Does SwiftUI defer view creation even when we create NSHostingController?**
   - Test by accessing .view property
   - Check if ViewModel init logs appear earlier

4. **Is the Task actually scheduled at init time?**
   - Try DispatchQueue.main.async instead
   - Use Task.detached to bypass main thread scheduling

5. **Are we looking at the wrong logs?**
   - Check Console.app for ALL app logs
   - Verify log subsystem is correct

---

## Success Criteria

When fixed, we should see this log sequence:

```
[App Launch - T+0s]
🚀 App launched - forcing controller initialization
🎮 Initializing controller
🎮 Forcing view materialization
🎮 Hosting controller created
🧠 ViewModel initialized - pre-warming zero state
✅ Controller initialized at startup
🔥 Starting zero-state pre-warm

[Backend - T+1s]
[ZeroState] GET request received
[ZeroState] Request received: history_size=0
[ZeroState] Response returned: count=4

[Swift - T+2s]
🔥 Pre-warm complete: 4 suggestions cached

[User Action - T+30s]
🪟 Opening window
[Zero state appears instantly - no shimmer]
```

---

## Files Modified (For Reference)

1. `apps/mac/FamiliarApp/Sources/FamiliarApp/Support/AppDelegate.swift` (created)
2. `apps/mac/FamiliarApp/Sources/FamiliarApp/App.swift` (added @NSApplicationDelegateAdaptor)
3. `apps/mac/FamiliarApp/Sources/FamiliarApp/UI/FamiliarWindow.swift` (made hostingController non-lazy)
4. `apps/mac/FamiliarApp/Sources/FamiliarApp/UI/FamiliarViewModel.swift` (added Task for pre-warming)
5. `scripts/restart-familiar.sh` (start log viewer before app)
6. `scripts/watch-logs.sh` (created for log streaming)
7. `backend/src/palette_sidecar/api.py` (added [ZeroState] logging)

---

## Next Session Actions

1. Run Priority 1 test (filesystem marker) to confirm AppDelegate runs
2. If AppDelegate doesn't run: Switch to traditional NSApplicationMain pattern
3. If AppDelegate runs but logs don't show: Check Console.app for timing issue
4. If everything runs but Task doesn't fire: Try DispatchQueue.main.async
5. If all else fails: Consider moving cache to AppState with explicit startup fetch
