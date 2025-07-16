import SwiftUI

struct ShowcaseRow: View {
	let mode: Mode

	var body: some View {
		VStack(alignment: .leading) {
			Text(mode.body)
				.font(.body)
			Text(mode.caption)
				.font(.caption)
		}
		.frame(maxWidth: .infinity, alignment: .leading)
		.contentShape(Rectangle())
	}
}

struct ShowcasesList: View {

	let sectionTitle: String
	let modes: [Mode]

	@Binding var shownMode: Mode?

	var body: some View {
		List {
			Section(sectionTitle) {
				ForEach(modes) { mode in
					ShowcaseRow(mode: mode)
						.onTapGesture {
							shownMode = mode
						}
				}
			}
		}
	}
}
