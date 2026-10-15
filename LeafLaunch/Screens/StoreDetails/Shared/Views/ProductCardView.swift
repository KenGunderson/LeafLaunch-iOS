import SwiftUI

struct ProductCardView: View {

    @Environment(\.style) private var style
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let product: Product
    let imageURL: URL?
    var isImageLoading: Bool = false
    let isFavorite: Bool
    let onOpen: () -> Void
    let onFavorite: () -> Void

    var body: some View {

        Group {

            VStack(alignment: .leading, spacing: 0) {

                ProductImageView(
                    url: self.imageURL,
                    accessibilityLabel: self.product.displayName,
                    isLoading: self.isImageLoading,
                    isUnavailable: !self.product.activeImages.isEmpty
                )
                .aspectRatio(contentMode: .fill)
                .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: self.style.spacing(.small)) {

                    if let category = self.product.category?.name {

                        Text(category)
                            .appFont(with: .NOTE_1)
                            .foregroundStyle(.text(.body))

                    }

                    Text(self.product.displayName)
                        .appFont(with: .TITLE_3)
                        .foregroundStyle(.text(.title))
                        .fixedSize(horizontal: false, vertical: true)

                    ProductPriceView(product: self.product)

                }
                .padding(.medium)
                .frame(maxWidth: .infinity, alignment: .leading)

            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.background(.secondary))
            .clipShape(RoundedRectangle(cornerRadius: self.style.radius(.large)))
            .overlay {

                RoundedRectangle(cornerRadius: self.style.radius(.large))
                    .strokeBorder(self.style.background(.border), lineWidth: 1)

            }

        }
        .asButton(scale: self.reduceMotion ? 1 : nil, action: self.onOpen)
        .accessibilityHint(String(localized: "View product details"))
        .overlay(alignment: .topTrailing) {

            ProductFavoriteButton(
                isFavorite: self.isFavorite,
                productName: self.product.displayName,
                action: self.onFavorite
            )
            .padding(.small)

        }

    }

}

#Preview {

    @Previewable @State var isFavorite = false

    if let product = MockCustomerModels.products.first {

        ProductCardView(
            product: product,
            imageURL: MockCustomerModels.previewCoverImageURLs[product.id],
            isFavorite: isFavorite,
            onOpen: {},
            onFavorite: { isFavorite.toggle() }
        )
        .containerRelativeFrame(.horizontal, count: 2, spacing: 0)
        .padding(.medium)
        .withMockPreviews()

    }

}
