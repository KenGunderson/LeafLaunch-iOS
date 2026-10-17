import SwiftUI

struct ProductOptionsView: View {

    @Environment(\.style) private var style

    let product: Product
    var contentInset: CGFloat = 0

    var body: some View {

        if self.product.variants.isEmpty {

            Text(String(localized: "No Pricing Options Available"))
                .appFont(with: .BODY_2)
                .foregroundStyle(.text(.body))
                .padding(.horizontal, self.contentInset)

        } else {

            pricingOptions()

        }

    }

    @ViewBuilder
    private func pricingOptions() -> some View {

        ScrollView(.horizontal, showsIndicators: false) {

            HStack(alignment: .top, spacing: self.style.spacing(.small)) {

                ForEach(self.product.variants, id: \.id) { variant in
                    option(variant)
                }

            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(.vertical, .extraSmall)

        }
        .safeAreaPadding(.horizontal, self.contentInset)

    }

    @ViewBuilder
    private func option(_ variant: ProductPricing) -> some View {

        AppOutlineCardView(
            verticalPadding: .small2,
            horizontalPadding: .small2,
            backgroundStyle: .background(.secondary),
            outlineColor: .background(.border),
            outlineWidth: 1,
            cornerRadius: .medium
        ) {

            VStack(alignment: .leading, spacing: self.style.spacing(.small)) {

                optionName(variant)
                price(variant)
                availability(variant)

                if variant.promotionId != nil {

                    Text(String(localized: "Promotion Applied"))
                        .appFont(with: .NOTE_1)
                        .foregroundStyle(.text(.body))
                        .fixedSize(horizontal: false, vertical: true)

                }

            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

        }
        .frame(width: 128)
        .frame(maxHeight: .infinity, alignment: .top)

    }

    @ViewBuilder
    private func optionName(_ variant: ProductPricing) -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.extraSmall)) {

            Text(String(localized: "Size"))
                .appFont(with: .NOTE_1)
                .foregroundStyle(.text(.body))

            Text(variant.name)
                .appFont(with: .TITLE_3)
                .foregroundStyle(.text(.title))
                .fixedSize(horizontal: false, vertical: true)

        }

    }

    @ViewBuilder
    private func availability(_ variant: ProductPricing) -> some View {

        let isAvailable = self.product.status == .published && variant.availability == .available

        Text(isAvailable ? String(localized: "Available") : String(localized: "Sold Out"))
            .appFont(with: .NOTE_1)
            .foregroundStyle(isAvailable ? self.style.foreground(.primary) : self.style.textColor(.body))
            .fixedSize(horizontal: false, vertical: true)

    }

    @ViewBuilder
    private func price(_ variant: ProductPricing) -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.extraSmall)) {

            if let price = variant.displayPrice {

                Text(price.formatted(.currency(code: self.product.currencyCode)))
                    .appFont(with: .TITLE_5)
                    .foregroundStyle(.text(.title))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .fixedSize(horizontal: false, vertical: true)

            } else {

                Text(String(localized: "Price Unavailable"))
                    .appFont(with: .BODY_1)
                    .foregroundStyle(.text(.body))
                    .fixedSize(horizontal: false, vertical: true)

            }

            if let basePrice = variant.baseDisplayPrice,
               let displayPrice = variant.displayPrice,
               basePrice > displayPrice {

                let formattedBasePrice = basePrice.formatted(.currency(code: self.product.currencyCode))

                Text(formattedBasePrice)
                    .appFont(with: .NOTE_1)
                    .foregroundStyle(.text(.body))
                    .strikethrough()
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .fixedSize(horizontal: false, vertical: true)

            }

        }

    }

}

#Preview {

    if let product = MockCustomerModels.products.first {

        ProductOptionsView(product: product)
            .padding(.medium)
            .withMockPreviews()

    }

}
