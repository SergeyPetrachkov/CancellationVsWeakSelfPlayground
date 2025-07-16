# WeakSelfPlayground

> **Educational iOS SwiftUI app demonstrating memory management patterns in async Swift code**

An interactive playground showcasing different approaches to handling weak references, task cancellation, and memory leaks in asynchronous Swift operations. Perfect for learning Swift concurrency best practices and understanding common pitfalls.

## 🎯 Purpose

This app demonstrates the critical differences between various memory management patterns when dealing with:
- Single async tasks vs infinite async sequences
- Weak self capture vs task cancellation vs guard let patterns
- Memory leaks and proper cleanup strategies

## 📱 Features

### Two Main Categories:

1. **SingleTask Tab** - Memory management for finite async operations
2. **AsyncSequence Tab** - Memory management for infinite async streams

### Interactive Testing:
- Live console output showing object lifecycles
- Real-time memory leak detection through deinit messages
- Immediate feedback via app switching notifications

## 🏗️ Architecture

The app uses a **View - Interactor - Presenter (VIP)** pattern to build screens just to show how Tasks retain entities and what stays in memory. (VIP just has a lot of components, very convenient for the demo purposes).

### Key Components:

- **`Interactor`**: Handles async operations and business logic
- **`Presenter`**: Manages state updates and UI communication  
- **`ViewController`**: UIKit view controller with progress indicator
- **`LongService`**: Simulates long-running async operations
- **`UIViewControllerRepresentable`**: Bridges UIKit to SwiftUI

## 🔬 Memory Management Patterns

The app demonstrates 9 different approaches to async memory management:

### Single Task Patterns (`Cases/SimpleCaseStack.swift`)

| Pattern | Description | Memory Behavior | Use Case |
|---------|-------------|----------------|----------|
| **NoWeakInteractor** | No capture list | Everything in memory until Task finishes | ❌ Demonstrates the problem |
| **WeakInteractor** | `[weak self]` capture | Immediate deallocation, task continues | ✅ Fire-and-forget operations |
| **CancellationInteractor** | Task storage + cancellation | Immediate cleanup + task termination | ✅ User-initiated operations |
| **GuardLetInteractor** | `[weak self] + guard let self` | Extended lifetime until task completes | ⚠️ Educational anti-pattern |
| **DeinitCancellationInteractor** | Cancels task in `deinit` | Cleanup when object is deallocated | ✅ Alternative cleanup timing |

### Async Sequence Patterns (`Cases/AsyncSequenceStack.swift`)

| Pattern | Description | Memory Behavior | Use Case |
|---------|-------------|----------------|----------|
| **InfiniteSequenceInteractor** | No capture list | Memory leak until app termination | ❌ Demonstrates infinite leak |
| **WeakSequenceInteractor** | `[weak self]` capture | Immediate deallocation, sequence continues | ⚠️ Well, better than nothing :D |
| **CancelSequenceInteractor** | Task storage + cancellation | Immediate cleanup + sequence termination | ✅ **Recommended** |
| **GuardLetSequenceInteractor** | `[weak self] + guard let self` | Memory leak until app termination | ❌ Catastrophic pattern |

## 🧪 Testing Instructions

### Quick Start:
1. Open project in Xcode 16.3+ 
2. Run on iOS 18.4+ simulator or device
3. Navigate between tabs and test each pattern

### Memory Leak Detection:
1. Tap any pattern button to open the demo
2. **Immediately dismiss** the sheet (swipe down)
3. Watch console output for `deinit` messages
4. **Missing deinit = Memory leak detected** 🚨

### Testing Async Sequences:
1. Open any AsyncSequence pattern
2. Switch to another app and back (triggers notifications)
3. Dismiss the sheet
4. Switch apps again - watch for continued console logs
5. Continued logs = sequence still running (potential issue)

## 🎓 Learning Outcomes

### Key Insights:
- **Async operations can outlive their creating views**
- **Infinite sequences are more dangerous than single tasks**
- **Context determines pattern appropriateness**
- **Cancellation is essential for sequences, optional(but still highly recommended!) for tasks**

### Common Pitfalls Demonstrated:
- Forgetting capture lists in async contexts
- Using `guard let self` in long-running operations without cancellation handling
- Not canceling infinite async sequences
- Assuming weak self always prevents memory issues

## 📂 Project Structure

```
WeakSelfPlayground/
├── WeakSelfPlayground/
│   ├── Cases/
│   │   ├── SimpleCaseStack.swift      # Single task patterns
│   │   └── AsyncSequenceStack.swift   # Infinite async sequences
│   ├── SharedLogic/
│   │   └── Shared.swift               # Core architecture components
│   ├── SwiftUIWrappers/
│   │   └── WeakController.swift       # UIKit-SwiftUI bridge
│   ├── ContentView.swift              # Main navigation
│   └── WeakSelfPlaygroundApp.swift    # App entry point
└── README.md
```

## 🛠️ Technical Requirements

- **iOS 18.4+**
- **Swift 6.0** with strict concurrency
- **Xcode 16.3+**
- Uses modern Swift concurrency (`async/await`, `Task`, `AsyncSequence`)

## 🚀 Getting Started

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd WeakSelfPlayground
   ```

2. **Open in Xcode**
   ```bash
   open WeakSelfPlayground.xcodeproj
   ```

3. **Run the app**
   - Select a simulator or device
   - Press `Cmd+R` to build and run

4. **Start exploring**
   - Try each pattern in both tabs
   - Watch console output carefully
   - Experiment with different timing scenarios

## 📚 Educational Value

This playground is ideal for:
- **iOS developers** learning Swift concurrency
- **Code review training** on memory management
- **Team workshops** on async programming best practices
- **Interview preparation** on iOS memory management

## 🤝 Contributing

This is an educational project. Feel free to:
- Add new memory management patterns
- Improve documentation
- Suggest additional test scenarios
- Report issues or unclear explanations

## 📝 Memory Management Best Practices
- Store and cancel tasks in `viewDidUnload()` or `deinit` when appropriate
- Choose cancellation timing based on cleanup requirements:
  - `viewDidUnload()` for view-lifecycle bound operations
  - `deinit` for more flexible cleanup timing
- Avoid `guard let self` for operations that outlive the view controller
