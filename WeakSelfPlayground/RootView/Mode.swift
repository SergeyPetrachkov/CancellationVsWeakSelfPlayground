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
	/// cancel task in deinit
	case deinitCancellation

	/// leak caused by infinite uncancelled sequence
	case infiniteSequence
	/// weak self to avoid leaks
	case weakSequence
	/// cancellation handling to avoid leaks
	case cancelSequence
	/// danger of guard-let that can lead to leaks
	case guardLetSequence

	var body: String {
		switch self {
		case .noWeakSelf, .infiniteSequence:
			"No Weak self"
		case .weakSelf, .weakSequence:
			"Weak self"
		case .cancellation, .cancelSequence:
			"Cancellation"
		case .guardLet, .guardLetSequence:
			"Guard let"
		case .deinitCancellation:
			"Cancel task in deinit"
		}
	}

	var caption: String {
		switch self {
		case .noWeakSelf, .infiniteSequence:
			"self is implicitly retained"
		case .weakSelf, .weakSequence:
			"[weak self] capture in Task"
		case .cancellation, .cancelSequence:
			"Task is stored in a property and cancelled manually"
		case .guardLet, .guardLetSequence:
			"[weak self] + guard let self in Task"
		case .deinitCancellation:
			"[weak self] + cancellation in deinit"
		}
	}
}
