import Foundation
import UIKit

@MainActor
protocol Interactor {
	func viewDidLoad()
	func viewDidUnload()
}

final class LongService: Sendable {

	init() {}

	deinit {
		print("\(self) deinit at \(Date.now)")
	}

	func doSomething() async throws {
		try await Task.sleep(for: .seconds(5))
	}

	func doSomethingElse() async throws {
		try await Task.sleep(for: .seconds(2))
	}
}

struct ViewState: Sendable {
	let text: String
}

@MainActor
final class Presenter {

	weak var controller: ViewController?

	deinit {
		print("\(self) deinit")
	}

	func present(state: ViewState) {
		controller?.update(state: state)
	}
}

final class ViewController: UIViewController {

	let interactor: any Interactor

	let progressIndicator = UIActivityIndicatorView(style: .large)
	let label = UILabel(frame: .zero)

	init(interactor: some Interactor) {
		self.interactor = interactor
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	deinit {
		print("\(self) deinit at \(Date.now)")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		label.numberOfLines = 0
		label.text = "Updating..."
		label.textAlignment = .center
		view.addSubview(progressIndicator)
		view.addSubview(label)
		progressIndicator.translatesAutoresizingMaskIntoConstraints = false
		progressIndicator.tintColor = .darkText
		progressIndicator.startAnimating()
		label.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate(
			[
				progressIndicator.widthAnchor.constraint(equalToConstant: 50),
				progressIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
				progressIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

				label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
				label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
				label.topAnchor.constraint(equalTo: progressIndicator.bottomAnchor, constant: 16),
			]
		)
		interactor.viewDidLoad()
	}

	override func willMove(toParent parent: UIViewController?) {
		if parent == nil {
			interactor.viewDidUnload()
		}
		super.willMove(toParent: parent)
	}

	func update(state: ViewState) {
		label.text = state.text
	}
}
