import SwiftUI

struct ProductOptionsView: View {

    @Environment(\.style) private var style

    let product: Product

    var body: some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.medium)) {

            CommerceSectionHeader(title: String(localized: "Options & pricing"))

            CommerceSurface {

                VStack(alignment: .leading, spacing: self.style.spacing(.medium)) {

                    if self.product.variants.isEmpty {

                        Text(String(localized: "No pricing options available."))
                            .appFont(with: .BODY_2)
                            .foregroundStyle(.text(.body))

                    }

                    ForEach(self.product.variants, id: \.id) { variant in

                        if variant.id != self.product.variants.first?.id {
                            Divider()
                        }

                        option(variant)

                    }

                }

            }

        }

    }

    private func option(_ variant: ProductPricing) -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.small)) {

            ViewThatFits(in: .horizontal) {

                HStack(alignment: .firstTextBaseline, spacing: self.style.spacing(.medium)) {

                    Text(variant.name)
                        .appFont(with: .TITLE_3)
                        .foregroundStyle(.text(.title))

                    Spacer(minLength: 0)
                    price(variant)

                }

                VStack(alignment: .leading, spacing: self.style.spacing(.small)) {

                    Text(variant.name)
                        .appFont(with: .TITLE_3)
                        .foregroundStyle(.text(.title))

                    price(variant)

                }

            }

            let isAvailable = self.product.status == .published && variant.availability == .available

            HStack(alignment: .firstTextBaseline, spacing: self.style.spacing(.small)) {

                ImageSource.systemImage(isAvailable ? "checkmark.circle" : "minus.circle")
                    .view(shouldResize: false)
                    .accessibilityHidden(true)

                Text(isAvailable ? String(localized: "Available") : String(localized: "Currently unavailable"))

            }
            .appFont(with: .NOTE_1)
            .foregroundStyle(isAvailable ? self.style.foreground(.primary) : self.style.textColor(.body))

            if variant.promotionId != nil {

                Text(String(localized: "Promotion applied"))
                    .appFont(with: .NOTE_1)
                    .foregroundStyle(.text(.body))

            }

        }
        .accessibilityElement(children: .combine)

    }

    private func price(_ variant: ProductPricing) -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.extraSmall)) {

            if let price = variant.displayPrice {

                Text(price.formatted(.currency(code: self.product.currencyCode)))
                    .appFont(with: .TITLE_3)
                    .foregroundStyle(.text(.title))

            } else {

                Text(String(localized: "Price unavailable"))
                    .appFont(with: .BODY_1)
                    .foregroundStyle(.text(.body))

            }

            if let basePrice = variant.baseDisplayPrice,
               let displayPrice = variant.displayPrice,
               basePrice > displayPrice {

                let formattedBasePrice = basePrice.formatted(.currency(code: self.product.currencyCode))

                Text(formattedBasePrice)
                    .appFont(with: .NOTE_1)
                    .foregroundStyle(.text(.body))
                    .strikethrough()
                    .accessibilityLabel(String(localized: "Regular price \(formattedBasePrice)"))

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
