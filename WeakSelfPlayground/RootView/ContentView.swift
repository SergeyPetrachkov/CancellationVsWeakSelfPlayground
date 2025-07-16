import SwiftUI

struct ContentView: View {

	@State private var shownMode: Mode?

	var body: some View {
		TabView {
			Tab("SingleTask", systemImage: "person") {
				ShowcasesList(
					sectionTitle: "Single Unstructured Task",
					modes: [Mode.noWeakSelf, .weakSelf, .cancellation, .guardLet, .deinitCancellation],
					shownMode: $shownMode
				)
			}

			Tab("AsyncSequence", systemImage: "person.3.sequence") {
				ShowcasesList(
					sectionTitle: "Async Sequence within a Task",
					modes: [Mode.infiniteSequence, .weakSequence, .cancelSequence, .guardLetSequence],
					shownMode: $shownMode
				)
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
			case .deinitCancellation:
				DeinitCancellationController()
			}
		}
		.navigationTitle("Swift Concurrency")
	}
}

#Preview {
	ContentView()
}
