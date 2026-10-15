import SwiftUI

struct ProductDetailsSummaryView: View {

    @Environment(\.style) private var style

    let product: Product
    let isFavorite: Bool
    let onFavorite: () -> Void

    var body: some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.small2)) {

            let categories = [self.product.category?.name, self.product.subcategory?.name]
                .compactMap { $0 }
                .joined(separator: " · ")

            if !categories.isEmpty {

                Text(categories)
                    .appFont(with: .SUBTITLE_1)
                    .foregroundStyle(.text(.body))

            }

            HStack(alignment: .top, spacing: self.style.spacing(.medium)) {

                Text(self.product.displayName)
                    .appFont(with: .HEADER_3)
                    .foregroundStyle(.text(.title))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)

                ProductFavoriteButton(
                    isFavorite: self.isFavorite,
                    productName: self.product.displayName,
                    action: self.onFavorite
                )

            }

            ProductPriceView(product: self.product)

        }
        .frame(maxWidth: .infinity, alignment: .leading)

    }

}

#Preview {

    @Previewable @State var isFavorite = false

    if let product = MockCustomerModels.products.first {

        ProductDetailsSummaryView(
            product: product,
            isFavorite: isFavorite,
            onFavorite: { isFavorite.toggle() }
        )
        .padding(.medium)
        .withMockPreviews()

    }

}
