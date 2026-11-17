import SwiftUI

struct ProductCardView: View {

    @Environment(\.style) private var style

    let product: Product
    let isFavorite: Bool
    let onOpen: () -> Void
    let onFavorite: () -> Void

    var body: some View {

        LLAppCardView(
            verticalPadding: .none,
            horizontalPadding: .none,
            cornerRadius: .medium2
        ) {
            content()
        }
        .runeAsButton(action: self.onOpen)
        .overlay(alignment: .topTrailing) {

            favoriteAction()
                .runePadding(LLSpacing.metadata)

        }

    }

    @ContentBuilder
    private func content() -> some View {

        VStack(
            alignment: .leading,
            spacing: self.style.spacing(LLSpacing.none)
        ) {

            ProductImageView(
                url: self.product.activeImages.first?.url,
                isUnavailable: !self.product.activeImages.isEmpty
            )
            .aspectRatio(
                1.15,
                contentMode: .fit
            )
            .opacity(self.product.isAvailable ? 1 : 0.65)

            productDetails()

        }

    }

    @ContentBuilder
    private func productDetails() -> some View {

        VStack(
            alignment: .leading,
            spacing: self.style.spacing(LLSpacing.metadata)
        ) {

            Text(self.product.subcategory?.name ?? self.product.category?.name ?? "")
                .runeFont(with: .NOTE_2)
                .runeTextColor(.body)
                .lineLimit(
                    1,
                    reservesSpace: true
                )

            Text(self.product.displayName)
                .runeFont(with: .TITLE_3)
                .runeTextColor(.title)
                .lineLimit(
                    2,
                    reservesSpace: true
                )
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )

            ProductPriceView(
                product: self.product,
                font: .TITLE_4
            )
                .runePadding(.top, LLSpacing.groupedContent)

        }
        .runePadding(.horizontal, LLSpacing.cardContent)
        .runePadding(.vertical, LLSpacing.cardContent)
        .frame(maxWidth: .infinity, alignment: .leading)

    }

    @ContentBuilder
    private func favoriteAction() -> some View {

        ProductFavoriteButton(
            isFavorite: self.isFavorite,
            action: self.onFavorite
        )

    }

}

#Preview {

    @Previewable @State var isFavorite = false

    if let product = MockCustomerModels.products.first {

        ProductCardView(
            product: product,
            isFavorite: isFavorite,
            onOpen: {},
            onFavorite: { isFavorite.toggle() }
        )
        .frame(width: 225)
        .withMockPreviews()

    }

}
