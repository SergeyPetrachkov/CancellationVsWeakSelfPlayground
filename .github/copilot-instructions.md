# WeakSelfPlayground - AI Coding Instructions

## Project Overview
Educational iOS SwiftUI app demonstrating memory management patterns in async Swift code. The app showcases different approaches to handling weak references, task cancellation, and memory leaks in asynchronous operations.

## Architecture Pattern
The app uses a **View(Controller) - Interactor - Presenter (VIP)** architecture where:
- `Interactor` classes handle business logic and async operations
- `Presenter` manages state updates and UI communication
- `ViewController` (UIKit) handles UI display
- `UIViewControllerRepresentable` wrappers bridge UIKit to SwiftUI

## Key Components

### Core Architecture (`SharedLogic/Shared.swift`)
- `Interactor` protocol: Defines `viewDidLoad()` and `viewDidUnload()` lifecycle
- `LongService`: Simulates async operations with `Task.sleep()`
- `Presenter`: Weak reference to controller, handles state updates
- `ViewController`: Generic UIKit controller with activity indicator and label

### Memory Management Patterns
The app demonstrates 10 different approaches to async memory management:

**Single Task Patterns** (`Cases/SimpleCaseStack.swift`):
- `NoWeakInteractor`: No capture list (demonstrates memory retention)
- `WeakInteractor`: Uses `[weak self]` capture
- `CancellationInteractor`: Stores and cancels `Task` in `viewDidUnload()`
- `GuardLetInteractor`: Uses `guard let self` pattern (dangerous for long operations)
- `DeinitCancellationInteractor`: Cancels task in `deinit` (flexible cleanup timing)

**AsyncSequence Patterns** (`Cases/AsyncSequenceStack.swift`):
- `InfiniteSequenceInteractor`: No memory management (demonstrates leak)
- `WeakSequenceInteractor`: Uses `[weak self]` in async sequence
- `CancelSequenceInteractor`: Cancels stored task
- `GuardLetSequenceInteractor`: Uses `guard let self` (demonstrates partial leak)
- `DeinitCancelSequenceInteractor`: Combines weak self with deinit cancellation

### SwiftUI Integration (`SwiftUIWrappers/WeakController.swift`)
Each interactor has a corresponding `UIViewControllerRepresentable` wrapper that:
1. Creates presenter and interactor instances
2. Wires up the presenter-controller relationship
3. Returns configured `ViewController`

## Development Guidelines

### When Adding New Memory Management Examples
1. Create new interactor class implementing `Interactor` protocol
2. Add corresponding `UIViewControllerRepresentable` wrapper
3. Update `ContentView.swift` Mode enum and switch statement
4. Follow naming pattern: `[Pattern]Interactor` and `[Pattern]Controller`

### Memory Management Best Practices Demonstrated
- Always use `[weak self]` in Task closures for long-running operations
- Store and cancel tasks in `viewDidUnload()` when appropriate
- Avoid `guard let self` for operations that outlive the view controller
- Use deinit print statements for debugging memory leaks

### Testing Memory Management
Run the app and observe console output for deinit messages when dismissing views. Missing deinit logs indicate memory leaks.

### Project Structure
```
WeakSelfPlayground/
├── Cases/                    # Memory management pattern implementations
├── SharedLogic/              # Core architecture components
├── SwiftUIWrappers/          # UIKit-SwiftUI bridge components
└── RooView/                  # Main screen implementation
```

## Build & Run
Standard iOS project - open `WeakSelfPlayground.xcodeproj` in Xcode and run on simulator or device.
