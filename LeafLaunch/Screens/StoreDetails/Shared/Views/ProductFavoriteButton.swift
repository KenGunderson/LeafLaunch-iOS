import SwiftUI

struct ProductFavoriteButton: View {

    @Environment(\.style) private var style

    let isFavorite: Bool
    let action: () -> Void

    var body: some View {

        RNImageSource.systemImage(self.isFavorite ? "heart.fill" : "heart")
            .view()
            .frame(
                width: 18,
                height: 18
            )
            .foregroundStyle(self.isFavorite ? RNColorSource.palette(.link) : RNColorSource.text(.title))
            .frame(
                width: 32,
                height: 32
            )
            .runeBackground(.secondary)
            .clipShape(Circle())
            .overlay {

                Circle()
                    .strokeBorder(
                        RNColorSource.background(.border),
                        lineWidth: 0.8
                    )
                    .allowsHitTesting(false)

            }
            .frame(
                width: 44,
                height: 44
            )
            .contentShape(Rectangle())
            .runeAsButton {
                self.action()
            }
            .accessibilityLabel(self.isFavorite ? String(localized: "Remove From Saved Products") : String(localized: "Save Product"))
            .symbolEffect(
                .bounce,
                value: self.isFavorite
            )
            .animation(
                .bouncy,
                value: self.isFavorite
            )

    }

}

#Preview {

    @Previewable @State var isFavorite = false

    ProductFavoriteButton(
        isFavorite: isFavorite,
        action: { isFavorite.toggle() }
    )
    .runePadding(LLSpacing.pageInset)
    .withMockPreviews()

}
