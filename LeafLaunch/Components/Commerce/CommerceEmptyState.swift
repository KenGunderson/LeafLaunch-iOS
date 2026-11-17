import SwiftUI

// A contextual empty state keeps the surrounding catalog filters and actions available.
struct CommerceEmptyState: View {

    @Environment(\.style) private var style

    let systemImage: String
    let title: String
    let message: String

    var body: some View {

        VStack(spacing: self.style.spacing(LLSpacing.section)) {

            RNImageSource.systemImage(self.systemImage)
                .view()
                .aspectRatio(contentMode: .fill)
                .frame(
                    width: 32,
                    height: 32
                )
                .runeForeground(.secondary)
                .runePadding(LLSpacing.pageInset)
                .background {

                    Circle()
                        .runeFill(.background(.tertiary))

                }

            Text(self.title)
                .runeFont(with: .TITLE_5)
                .runeTextColor(.title)

            Text(self.message)
                .runeFont(with: .BODY_2)
                .runeTextColor(.body)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )

        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .runePadding(.vertical, LLSpacing.content)
        .runePadding(.horizontal, LLSpacing.pageInset)

    }

}

#Preview {

    CommerceEmptyState(
        systemImage: "heart",
        title: "No Favorites Yet",
        message: "Save a product to find it here later."
    )
    .withMockPreviews()

}
