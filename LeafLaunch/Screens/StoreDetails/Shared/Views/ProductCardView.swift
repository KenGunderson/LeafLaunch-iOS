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
        .asButton(action: self.onOpen)
        .overlay(alignment: .topTrailing) {
            favoriteAction()
                .padding(.extraSmall)
        }

    }

    @ViewBuilder
    private func content() -> some View {

        VStack(alignment: .leading, spacing: 0) {

            ProductImageView(
                url: self.product.activeImages.first?.url,
                isUnavailable: !self.product.activeImages.isEmpty
            )
            .aspectRatio(1.15, contentMode: .fit)
            .opacity(self.product.isAvailable ? 1 : 0.65)

            productDetails()

        }

    }

    @ViewBuilder
    private func productDetails() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.extraSmall)) {

            Text(self.product.subcategory?.name ?? self.product.category?.name ?? "")
                .appFont(with: .NOTE_2)
                .foregroundStyle(.text(.body))
                .lineLimit(1, reservesSpace: true)

            Text(self.product.displayName)
                .appFont(with: .TITLE_3)
                .foregroundStyle(.text(.title))
                .lineLimit(2, reservesSpace: true)
                .fixedSize(horizontal: false, vertical: true)

            ProductPriceView(product: self.product, font: .TITLE_4)
                .padding(.top, .small)

        }
        .padding(.horizontal, .small2)
        .padding(.vertical, .small2)
        .frame(maxWidth: .infinity, alignment: .leading)

    }

    @ViewBuilder
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
