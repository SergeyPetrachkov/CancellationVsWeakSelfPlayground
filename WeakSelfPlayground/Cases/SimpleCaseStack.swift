/*
 * SimpleCaseStack.swift
 *
 * MEMORY MANAGEMENT PATTERNS FOR SINGLE ASYNC TASKS
 * 
 * This file demonstrates four different cases related to handling memory management
 * in async Swift code with single unstructured Task operations. Each pattern shows different
 * trade-offs between safety, complexity, and performance.
 * 
 * The progression from NoWeakInteractor → WeakInteractor → GuardLetInteractor shows
 * how different capture strategies affect object lifetime and memory management.
 *
 * EDUCATIONAL PURPOSE:
 * - Compare no capture vs weak self vs task cancellation patterns
 * - See how guard-let affects weak capture and extends object lifetime
 * - Understand memory management scenarios in async/await code
 * - Learn proper cleanup strategies for long-running operations
 *
 * TESTING INSTRUCTIONS:
 * 1. Run the app and tap "SingleTask" tab
 * 2. Try each pattern button and immediately dismiss the sheet
 * 3. Observe console output for deinit messages
 * 4. Missing deinit = memory leak detected
 * 5. Pay attention to time stamps to see how long objects stay in memory
 *
 * PATTERNS DEMONSTRATED:
 * 
 * 1. NoWeakInteractor - MEMORY LEAK PATTERN (Educational)
 *    ❌ Task holds strong reference to self, preventing deallocation while the Task is running
 *    📝 Demonstrates the baseline problem of resources staying in memory longer than needed
 *
 * 2. WeakInteractor - WEAK REFERENCE PATTERN
 *    ✅ Uses [weak self] capture list - deallocates entities within VIP stack immediatelly
 *    ✅ Allows interactor to be deallocated while task continues
 *    ✅ Task continues but operations on nil self are safely ignored
 *    📝 Good for fire-and-forget operations where results aren't critical
 *
 * 3. CancellationInteractor - RECOMMENDED PATTERN
 *    ✅ Stores Task reference for explicit cancellation
 *    ✅ Immediately terminates async work on view dismissal
 *    ✅ Resource efficient: no wasted computation (if cancellation is handled correctly downstream)
 *    ✅ Clear semantics: operation explicitly cancelled vs silently ignored
 *    ⚠️ Slightly more complex (requires task storage)
 *    📝 Best for operations where early termination is desirable
 *
 * 4. GuardLetInteractor - EXTENDED LIFETIME PATTERN (Educational)
 *    ⚠️ Uses [weak self] + guard let self - creates temporary strong reference
 *    ⚠️ Prevents deallocation during entire async operation
 *    ⚠️ Objects stay in memory longer than necessary
 *    📝 Shows why guard let self can be problematic in long-running async contexts
 *
 * KEY INSIGHTS:
 * - Async operations can outlive the views that created them
 * - [weak self] prevents memory leaks but allows silent result discarding
 * - guard let self creates strong references that prevent cleanup until Task finishes
 * - Task cancellation provides immediate termination and resource efficiency
 * - Choose cancellation for user-initiated operations, weak self for background/fire-and-forget work
 * - Pay attention to timestamps in console output to understand object lifetimes
 * - Always monitor console output for deinit messages during development
 *
 * MEMORY LIFETIME PROGRESSION:
 * NoWeakInteractor:     Object lives until Task completes (7+ seconds)
 * WeakInteractor:       Object can die immediately when view dismissed
 * CancellationInteractor: Object dies immediately + Task terminates
 * GuardLetInteractor:   Object lives until Task completes (like NoWeak but with [weak self])
 */

import SwiftUI
import UIKit

final class NoWeakInteractor: Interactor {
	let presenter: Presenter
	let longService = LongService()

	init(presenter: Presenter) {
		self.presenter = presenter
	}

	deinit {
		print("\(self) deinit at \(Date.now)")
	}

	func viewDidLoad() {
		print("Started at: \(Date.now)")
		Task {
			try await longService.doSomething()
			try await longService.doSomethingElse()
			let state = ViewState(text: "Updated")
			presenter.present(state: state)
		}
	}

	func viewDidUnload() {
		print("Stopped at: \(Date.now)")
	}
}

final class WeakInteractor: Interactor {
	let presenter: Presenter
	let longService = LongService()

	init(presenter: Presenter) {
		self.presenter = presenter
	}

	deinit {
		print("\(self) deinit at \(Date.now)")
	}

	func viewDidLoad() {
		print("Started at: \(Date.now)")
		Task { [weak self] in
			try await self?.longService.doSomething()
			try await self?.longService.doSomethingElse()
			let state = ViewState(text: "Updated")
			self?.presenter.present(state: state)
		}
	}

	func viewDidUnload() {
		print("Stopped at: \(Date.now)")
	}
}

final class CancellationInteractor: Interactor {
	let presenter: Presenter
	let longService = LongService()

	var task: Task<Void, any Error>?

	init(presenter: Presenter) {
		self.presenter = presenter
	}

	deinit {
		print("\(self) deinit at \(Date.now)")
	}

	func viewDidLoad() {
		print("Started at: \(Date.now)")
		task = Task {
			try await longService.doSomething()
			try await longService.doSomethingElse()
			let state = ViewState(text: "Updated")
			presenter.present(state: state)
		}
	}

	func viewDidUnload() {
		print("Stopped at: \(Date.now)")
		task?.cancel()
	}
}

final class GuardLetInteractor: Interactor {
	let presenter: Presenter
	let longService = LongService()

	init(presenter: Presenter) {
		self.presenter = presenter
	}

	deinit {
		print("\(self) deinit at \(Date.now)")
	}

	func viewDidLoad() {
		print("Started at: \(Date.now)")
		Task { [weak self] in
			guard let self else { return }
			try await longService.doSomething()
			try await longService.doSomethingElse()
			let state = ViewState(text: "Updated")
			presenter.present(state: state)
		}
	}

	func viewDidUnload() {
		print("Stopped at: \(Date.now)")
	}
}
