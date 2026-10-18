import SwiftUI

struct ProductCardView: View {

    @Environment(\.style) private var style

    let product: Product
    let isFavorite: Bool
    let onOpen: () -> Void
    let onFavorite: () -> Void

    var body: some View {

        content()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.background(.secondary))
            .clipShape(RoundedRectangle(cornerRadius: self.style.radius(.medium2)))
            .overlay {

                RoundedRectangle(cornerRadius: self.style.radius(.medium2))
                    .strokeBorder(self.style.background(.border), lineWidth: 1)

            }
            .asButton(action: self.onOpen)
            .overlay(alignment: .topTrailing) {
                favoriteAction()
            }

    }

    @ViewBuilder
    private func content() -> some View {

        VStack(alignment: .leading, spacing: 0) {

            ProductImageView(
                url: self.product.activeImages.first?.url,
                isUnavailable: !self.product.activeImages.isEmpty
            )
            .frame(height: 192)

            productDetails()

        }

    }

    @ViewBuilder
    private func productDetails() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.extraSmall)) {

            Text(self.product.category?.name ?? "")
                .appFont(with: .NOTE_1)
                .foregroundStyle(.text(.body))
                .lineLimit(1, reservesSpace: true)

            Text(self.product.displayName)
                .appFont(with: .TITLE_3)
                .foregroundStyle(.text(.title))
                .lineLimit(2, reservesSpace: true)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)

            ProductPriceView(product: self.product)
                .frame(height: self.style.spacing(.large), alignment: .bottomLeading)

        }
        .padding(.horizontal, .small2)
        .padding(.vertical, .small)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 108, alignment: .topLeading)

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
