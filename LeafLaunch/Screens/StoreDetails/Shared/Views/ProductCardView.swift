import SwiftUI

struct ProductCardView: View {

    @Environment(\.style) private var style

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
                    isLoading: self.isImageLoading,
                    isUnavailable: !self.product.activeImages.isEmpty
                )
                .frame(height: 180)

                VStack(alignment: .leading, spacing: self.style.spacing(.small)) {

                    Text(self.product.category?.name ?? "")
                        .appFont(with: .NOTE_1)
                        .foregroundStyle(.text(.body))
                        .lineLimit(1, reservesSpace: true)

                    Text(self.product.displayName)
                        .appFont(with: .TITLE_3)
                        .foregroundStyle(.text(.title))
                        .lineLimit(1, reservesSpace: true)

                    ProductPriceView(product: self.product)
                        .lineLimit(1)

                }
                .padding(.medium)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 100, alignment: .bottomLeading)

            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.background(.secondary))
            .clipShape(RoundedRectangle(cornerRadius: self.style.radius(.large)))
            .overlay {

                RoundedRectangle(cornerRadius: self.style.radius(.large))
                    .strokeBorder(self.style.background(.border), lineWidth: 1)

            }

        }
        .overlay(alignment: .topTrailing) {

            ProductFavoriteButton(
                isFavorite: self.isFavorite,
                productName: self.product.displayName,
                action: self.onFavorite
            )
            .padding(.small)

        }
        .asButton(action: self.onOpen)

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
        .frame(width: 225)
        .withMockPreviews()

    }

}
