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

struct ViewState {
	let headline: String
	let text: String

	init(headline: String = "", text: String = "Updating...") {
		self.headline = headline
		self.text = text
	}
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
	let headline: UILabel = {
		let label = UILabel(frame: .zero)
		label.font = UIFont.preferredFont(forTextStyle: .headline)
		label.textAlignment = .left
		label.numberOfLines = 0
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	let body: UILabel = {
		let label = UILabel(frame: .zero)
		label.font = UIFont.preferredFont(forTextStyle: .body)
		label.text = "Updating..."
		label.textAlignment = .center
		label.numberOfLines = 0
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

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

		view.addSubview(headline)
		view.addSubview(body)
		view.addSubview(progressIndicator)

		progressIndicator.translatesAutoresizingMaskIntoConstraints = false
		progressIndicator.tintColor = .darkText
		progressIndicator.startAnimating()
		NSLayoutConstraint.activate(
			[
				headline.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
				headline.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
				headline.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),

				progressIndicator.widthAnchor.constraint(equalToConstant: 50),
				progressIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
				progressIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

				body.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
				body.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
				body.topAnchor.constraint(equalTo: progressIndicator.bottomAnchor, constant: 16),
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
		headline.text = state.headline
		body.text = state.text
	}
}
