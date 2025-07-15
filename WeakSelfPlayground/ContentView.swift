import SwiftUI

struct ContentView: View {

	enum Mode: Identifiable {
		var id: Mode {
			self
		}

		/// simply run an unstructured task
		case noWeakSelf
		/// weak self for the single unstructured task
		case weakSelf
		/// proper cancellation handling for the single unstructured task
		case cancellation
		/// retaining self via guard let in the single unstructured task
		case guardLet

		/// leak caused by infinite uncancelled sequence
		case infiniteSequence
		/// weak self to avoid leaks
		case weakSequence
		/// cancellation handling to avoid leaks
		case cancelSequence
		/// danger of guard-let that can lead to leaks
		case guardLetSequence
	}

	@State private var shownMode: Mode?

	var body: some View {
		TabView {
			Tab("SingleTask", systemImage: "person") {
				VStack(spacing: 8) {
					Button("No Weak self") {
						shownMode = .noWeakSelf
					}
					Button("Weak self") {
						shownMode = .weakSelf
					}
					Button("Cancellation") {
						shownMode = .cancellation
					}
					Button("GuardLet") {
						shownMode = .guardLet
					}
				}
			}

			Tab("AsyncSequence", systemImage: "person.3.sequence") {
				VStack(spacing: 8) {
					Button("Infinite sequence") {
						shownMode = .infiniteSequence
					}
					Button("Weak self") {
						shownMode = .weakSequence
					}
					Button("Cancellation") {
						shownMode = .cancelSequence
					}
					Button("GuardLet Danger") {
						shownMode = .guardLetSequence
					}
				}
			}
		}
		.sheet(item: $shownMode) { mode in
			switch mode {
			case .noWeakSelf:
				NoWeakController()
			case .weakSelf:
				WeakController()
			case .cancellation:
				CancellationController()
			case .guardLet:
				GuardLetController()
			case .weakSequence:
				WeakSequenceController()
			case .infiniteSequence:
				InfiniteSequenceController()
			case .cancelSequence:
				CancelSequenceController()
			case .guardLetSequence:
				GuardLetSequenceController()
			}
		}
	}
}

#Preview {
	ContentView()
}
