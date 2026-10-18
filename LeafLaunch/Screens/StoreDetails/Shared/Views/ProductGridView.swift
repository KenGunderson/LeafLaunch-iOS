import SwiftUI

struct ProductGridView: View {

    @Environment(\.style) private var style

    let products: [Product]
    let favoriteProductIds: Set<String>
    let onOpen: (String) -> Void
    let onFavorite: (String) -> Void

    private var columns: [GridItem] {

        Array(
            repeating: GridItem(.flexible(minimum: 0), spacing: self.style.spacing(.small), alignment: .top),
            count: 2
        )

    }

    var body: some View {

        LazyVGrid(columns: self.columns,
                  alignment: .leading,
                  spacing: self.style.spacing(.small)) {

            ForEach(self.products) { product in

                productCard(product)

            }

        }

    }

    @ViewBuilder
    private func productCard(_ product: Product) -> some View {

        ProductCardView(
            product: product,
            isFavorite: self.favoriteProductIds.contains(product.id),
            onOpen: { self.onOpen(product.id) },
            onFavorite: { self.onFavorite(product.id) }
        )

    }

}

#Preview {

    @Previewable @State var favoriteProductIds: Set<String> = []

    ScrollView {

        ProductGridView(
            products: Array(MockCustomerModels.products.prefix(4)),
            favoriteProductIds: favoriteProductIds,
            onOpen: { _ in },
            onFavorite: { productId in

                if favoriteProductIds.contains(productId) {
                    favoriteProductIds.remove(productId)
                } else {
                    favoriteProductIds.insert(productId)
                }

            }
        )
        .padding(.medium)

    }
    .withMockPreviews()

}
