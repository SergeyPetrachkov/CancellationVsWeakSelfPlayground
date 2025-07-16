/*
 * AsyncSequenceStack.swift
 *
 * MEMORY MANAGEMENT PATTERNS FOR ASYNC SEQUENCES
 * 
 * This file demonstrates five different approaches to handling memory management
 * in async Swift code with infinite AsyncSequence operations. Unlike single tasks,
 * async sequences can run indefinitely, making proper memory management critical
 * to prevent both memory leaks and resource waste.
 * 
 * The progression shows how different capture strategies affect object lifetime
 * when dealing with potentially infinite streams of data.
 *
 * EDUCATIONAL PURPOSE:
 * - Compare memory management patterns in long-running async sequences
 * - Understand how infinite loops affect object lifecycle
 * - See the differences between single tasks vs continuous sequences
 * - Learn when task cancellation becomes essential vs optional
 *
 * TESTING INSTRUCTIONS:
 * 1. Run the app and tap "AsyncSequence" tab
 * 2. Try each pattern button and immediately dismiss the sheet
 * 3. Observe console output for deinit messages
 * 4. Missing deinit = memory leak detected
 * 5. Pay attention to timestamps - sequences may run indefinitely
 * 6. To trigger notifications: switch to another app and back to see immediate results
 * 7. Each app switch will generate "Received notification" logs - watch for patterns
 *
 * PATTERNS DEMONSTRATED:
 * 
 * 1. InfiniteSequenceInteractor - MEMORY LEAK PATTERN (Educational)
 *    ❌ No capture list - self is retained by a strong reference
 *    ❌ Infinite loop prevents deallocation indefinitely
 *    ❌ Objects stay in memory until app termination
 *    📝 Demonstrates why async sequences are more dangerous than single tasks
 *    🧪 Test: Switch apps - you'll see "Received notification" logs even after dismissing sheet
 *
 * 2. WeakSequenceInteractor - WEAK REFERENCE PATTERN
 *    ✅ Uses [weak self] capture list - allows immediate deallocation
 *    ✅ Sequence continues but operations on nil self are safely ignored
 *    ❌ Sequence loop continues running even after objects are deallocated
 *    📝 Ok for non-critical background monitoring if resource waste is acceptable
 *    🧪 Test: Switch apps - you'll see "Received notification" logs but no UI updates
 *
 * 3. CancelSequenceInteractor - RECOMMENDED PATTERN
 *    ✅ Stores Task reference for explicit cancellation
 *    ✅ Immediately terminates infinite sequence on view dismissal
 *    ✅ Resource efficient: stops unnecessary async work completely
 *    ✅ Clear semantics: sequence explicitly stopped vs silently ignored
 *    📝 Best practice for async sequences - always store and cancel tasks
 *    🧪 Test: Switch apps - no "Received notification" logs after dismissing sheet
 *
 * 4. GuardLetSequenceInteractor - EXTENDED LIFETIME PATTERN (Educational)
 *    ⚠️ Uses [weak self] + guard let self - creates temporary strong reference
 *    ⚠️ Prevents deallocation during the entire sequence duration
 *    ❌ Effectively same as InfiniteSequenceInteractor for infinite sequences
 *    📝 Shows why guard let self is particularly dangerous with async sequences
 *    🧪 Test: Switch apps - you'll see "Received notification" logs even after dismissing sheet
 *
 * 5. DeinitCancelSequenceInteractor - ALTERNATIVE CANCELLATION PATTERN
 *    ✅ Combines [weak self] with task cancellation in deinit
 *    ✅ Allows immediate deallocation of view controllers
 *    ✅ Guarantees task cleanup when interactor is deallocated
 *    📝 Good for cases where view dismissal and task cancellation can be decoupled
 *    🧪 Test: Switch apps - no logs after interactor is deallocated
 *
 * KEY INSIGHTS:
 * - Async sequences are more dangerous than single tasks for memory management
 * - Infinite sequences without cancellation = guaranteed memory leaks
 * - [weak self] allows deallocation but doesn't stop the sequence loop
 * - guard let self + infinite sequence = permanent memory retention
 * - Task cancellation is essential (not optional) for async sequences
 * - NotificationCenter.publisher creates potentially infinite streams
 * - Always store and cancel Task references for async sequence operations
 * - UIApplication.didBecomeActiveNotification fires on every app switch - perfect for testing
 * - Console logs show "Received notification" for each event - easy to verify behavior
 *
 * MEMORY LIFETIME COMPARISON:
 * InfiniteSequenceInteractor:    Object lives until app termination
 * WeakSequenceInteractor:        Object can die immediately, sequence continues
 * CancelSequenceInteractor:      Object dies immediately + sequence terminates
 * GuardLetSequenceInteractor:    Object lives until app termination (like Infinite)
 * DeinitCancelSequenceInteractor: Object dies on deinit + sequence terminates
 *
 * ASYNC SEQUENCE vs SINGLE TASK:
 * - Single tasks eventually complete, sequences may never complete
 * - Weak self is "acceptable" for tasks, "problematic" for sequences
 * - Cancellation is "nice to have" for tasks, "essential" for sequences
 * - Guard let is "dangerous" for tasks, "catastrophic" for sequences
 */

import UIKit
import SwiftUI

final class InfiniteSequenceInteractor: Interactor {
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
		presenter.present(state: ViewState(headline: "\(self)"))
		// Self is strongly retained and it will never deallocate. Only the controller can be deallocated.
		// ❌ Task will run infinitely and Service and Presenter will execute operations until the process terminates.
		Task {
			for await notification in NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification).values {
				print("Received notification \(notification)")
				try await longService.doSomethingElse()
				let state = ViewState(text: "Updated with new value: \(notification)")
				presenter.present(state: state)
			}
			print("Task finished at \(Date.now)")
		}
	}

	func viewDidUnload() {
		print("Stopped \(self) at: \(Date.now)")
	}
}

final class WeakSequenceInteractor: Interactor {
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
		presenter.present(state: ViewState(headline: "\(self)"))
		// Deallocation Sequence: Controller --> Interactor --> Presenter --> Service
		// ❌ BUT the Task is kept in memory forever (until the process terminates) and notifications will keep comming and printing
		Task { [weak self] in
			for await notification in NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification).values {
				print("Received notification \(notification)")
				try await self?.longService.doSomethingElse()
				let state = ViewState(text: "Updated with new value: \(notification)")
				self?.presenter.present(state: state)
			}
			print("Task finished at \(Date.now)")
		}
	}

	func viewDidUnload() {
		print("Stopped \(self) at: \(Date.now)")
	}
}

final class CancelSequenceInteractor: Interactor {
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
		presenter.present(state: ViewState(headline: "\(self)"))
		// Deallocation Sequence: ...(Task cancelled in willMove(to: nil))... Controller --> ... (print that the task is finished) .... -> Interactor --> Presenter --> Service
		// ✅ Task is correctly cancelled, the sequence will finish without errors (it's the implementation detail of the NC) and
		// print(Task finished at) will be executed
		task = Task {
			for await notification in NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification).values {
				print("Received notification \(notification)")
				try await longService.doSomethingElse()
				let state = ViewState(text: "Updated with new value: \(notification)")
				presenter.present(state: state)
			}
			print("Task finished at \(Date.now)")
		}
	}

	func viewDidUnload() {
		print("Stopped \(self) at: \(Date.now)")
		task?.cancel()
	}
}

final class GuardLetSequenceInteractor: Interactor {
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
		presenter.present(state: ViewState(headline: "\(self)"))
		// Self is strongly retained and it will never deallocate. Only the controller can be deallocated.
		// ❌ Task will run infinitely and Service and Presenter will execute operations until the process terminates.
		Task { [weak self] in
			guard let self else { return }
			for await notification in NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification).values {
				print("Received notification \(notification)")
				try await longService.doSomethingElse()
				let state = ViewState(text: "Updated with new value: \(notification)")
				presenter.present(state: state)
			}
			print("Task finished at \(Date.now)")
		}
	}

	func viewDidUnload() {
		print("Stopped \(self) at: \(Date.now)")
	}
}

final class DeinitCancelSequenceInteractor: Interactor {
	let presenter: Presenter
	let longService = LongService()

	var task: Task<Void, any Error>?

	init(presenter: Presenter) {
		self.presenter = presenter
	}

	deinit {
		print("\(self) deinit at \(Date.now)")
		task?.cancel()
	}

	func viewDidLoad() {
		print("Started at: \(Date.now)")
		presenter.present(state: ViewState(headline: "\(self)"))
		// Deallocation Sequence: Controller --> Interactor --> ... (Task cancelled) ... --> Presenter --> Service --> ... (print that the task is finished) ....
		task = Task { [weak self] in
			for await notification in NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification).values {
				print("Received notification \(notification)")
				try await self?.longService.doSomethingElse()
				let state = ViewState(text: "Updated with new value: \(notification)")
				self?.presenter.present(state: state)
			}
			print("Task finished at \(Date.now)")
		}
	}

	func viewDidUnload() {
		print("Stopped \(self) at: \(Date.now)")
	}
}
