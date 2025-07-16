import UIKit
import SwiftUI

struct NoWeakController: UIViewControllerRepresentable {
	typealias UIViewControllerType = ViewController

	func makeUIViewController(context: Context) -> UIViewControllerType {
		let presenter = Presenter()
		let interactor = NoWeakInteractor(presenter: presenter)
		let vc = ViewController(interactor: interactor)
		presenter.controller = vc
		return vc
	}

	func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {

	}
}

struct WeakController: UIViewControllerRepresentable {
	typealias UIViewControllerType = ViewController

	func makeUIViewController(context: Context) -> UIViewControllerType {
		let presenter = Presenter()
		let interactor = WeakInteractor(presenter: presenter)
		let vc = ViewController(interactor: interactor)
		presenter.controller = vc
		return vc
	}

	func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {

	}
}

struct CancellationController: UIViewControllerRepresentable {
	typealias UIViewControllerType = ViewController

	func makeUIViewController(context: Context) -> UIViewControllerType {
		let presenter = Presenter()
		let interactor = CancellationInteractor(presenter: presenter)
		let vc = ViewController(interactor: interactor)
		presenter.controller = vc
		return vc
	}

	func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {

	}
}

struct GuardLetController: UIViewControllerRepresentable {
	typealias UIViewControllerType = ViewController

	func makeUIViewController(context: Context) -> UIViewControllerType {
		let presenter = Presenter()
		let interactor = GuardLetInteractor(presenter: presenter)
		let vc = ViewController(interactor: interactor)
		presenter.controller = vc
		return vc
	}

	func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {

	}
}

struct DeinitCancellationController: UIViewControllerRepresentable {
	typealias UIViewControllerType = ViewController

	func makeUIViewController(context: Context) -> UIViewControllerType {
		let presenter = Presenter()
		let interactor = DeinitCancellationInteractor(presenter: presenter)
		let vc = ViewController(interactor: interactor)
		presenter.controller = vc
		return vc
	}

	func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {

	}
}

struct InfiniteSequenceController: UIViewControllerRepresentable {

	typealias UIViewControllerType = ViewController

	func makeUIViewController(context: Context) -> UIViewControllerType {
		let presenter = Presenter()
		let interactor = InfiniteSequenceInteractor(presenter: presenter)
		let vc = ViewController(interactor: interactor)
		presenter.controller = vc
		return vc
	}

	func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {

	}
}


struct WeakSequenceController: UIViewControllerRepresentable {

	typealias UIViewControllerType = ViewController

	func makeUIViewController(context: Context) -> UIViewControllerType {
		let presenter = Presenter()
		let interactor = WeakSequenceInteractor(presenter: presenter)
		let vc = ViewController(interactor: interactor)
		presenter.controller = vc
		return vc
	}

	func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {

	}
}

struct CancelSequenceController: UIViewControllerRepresentable {

	typealias UIViewControllerType = ViewController

	func makeUIViewController(context: Context) -> UIViewControllerType {
		let presenter = Presenter()
		let interactor = CancelSequenceInteractor(presenter: presenter)
		let vc = ViewController(interactor: interactor)
		presenter.controller = vc
		return vc
	}

	func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {

	}
}

struct GuardLetSequenceController: UIViewControllerRepresentable {

	typealias UIViewControllerType = ViewController

	func makeUIViewController(context: Context) -> UIViewControllerType {
		let presenter = Presenter()
		let interactor = GuardLetSequenceInteractor(presenter: presenter)
		let vc = ViewController(interactor: interactor)
		presenter.controller = vc
		return vc
	}

	func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {

	}
}
