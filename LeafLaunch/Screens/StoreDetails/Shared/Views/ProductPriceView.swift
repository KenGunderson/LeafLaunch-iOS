import SwiftUI

struct ProductPriceView: View {

    @Environment(\.style) private var style

    let product: Product

    private var hasPriceRange: Bool {

        let prices = self.product.variants
            .filter { $0.availability == .available }
            .compactMap(\.displayPrice)

        return Set(prices).count > 1

    }

    var body: some View {

        Group {

            if let price = self.product.minimumPrice {

                let formattedPrice = price.formatted(.currency(code: self.product.currencyCode))

                VStack(alignment: .leading, spacing: self.style.spacing(.extraSmall)) {

                    Text(self.hasPriceRange ? String(localized: "From \(formattedPrice)") : formattedPrice)
                        .foregroundStyle(self.style.textColor(.title))

                    if let variant = self.product.variants.first(where: {

                        $0.availability == .available &&
                            $0.displayPrice == price &&
                            ($0.baseDisplayPrice ?? price) > price

                    }), let basePrice = variant.baseDisplayPrice {

                        let savings = (basePrice - price).formatted(.currency(code: self.product.currencyCode))

                        Text(String(localized: "Save \(savings) on \(variant.name)"))
                            .appFont(with: .NOTE_1)
                            .foregroundStyle(self.style.foreground(.primary))
                            .fixedSize(horizontal: false, vertical: true)

                    }

                }

            } else {

                let hasAvailableVariant = self.product.variants.contains { $0.availability == .available }

                Text(
                    self.product.status == .published && hasAvailableVariant
                        ? String(localized: "Price unavailable")
                        : String(localized: "Currently unavailable")
                )
                    .foregroundStyle(self.style.textColor(.body))

            }

        }
        .appFont(with: .TITLE_5)

    }

}

#Preview {

    if let product = MockCustomerModels.products.first {

        ProductPriceView(product: product)
            .padding(.medium)
            .withMockPreviews()

    }

}
