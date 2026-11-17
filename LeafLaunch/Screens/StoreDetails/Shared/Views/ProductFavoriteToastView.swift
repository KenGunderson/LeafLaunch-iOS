import SwiftUI
import UIKit

struct ProductFavoriteToastView: View {

    @Environment(\.style) private var style

    let productTitle: String
    let isFavorite: Bool

    var body: some View {

        LLAppCardView(
            verticalPadding: .small2,
            cornerRadius: .large
        ) {

            HStack(spacing: self.style.spacing(LLSpacing.cardContent)) {

                favoriteIcon()
                message()

            }

        }
        .frame(width: max(0, (UIScreen.currentWidth ?? 0) - 32))

    }

    @ContentBuilder
    private func favoriteIcon() -> some View {

        RNImageSource.systemImage(self.isFavorite ? "heart.fill" : "heart.slash.fill")
            .view()
            .scaledToFit()
            .frame(
                width: self.style.spacing(.large),
                height: self.style.spacing(.large)
            )
            .runeForeground(.primary)

    }

    @ContentBuilder
    private func message() -> some View {

        Text(
            self.isFavorite
                ? Constants.Message.favoriteProductAdded(self.productTitle)
                : Constants.Message.favoriteProductRemoved(self.productTitle)
        )
        .runeFont(with: .TITLE_3)
        .runeTextColor(.title)
        .fixedSize(
            horizontal: false,
            vertical: true
        )
        .frame(maxWidth: .infinity, alignment: .leading)

    }

}

#Preview {

    VStack(spacing: RNStyle.shared.spacing(LLSpacing.content)) {

        ProductFavoriteToastView(
            productTitle: "Cedar Reserve",
            isFavorite: true
        )
        ProductFavoriteToastView(
            productTitle: "Cedar Reserve",
            isFavorite: false
        )

    }
    .withMockPreviews()

}
