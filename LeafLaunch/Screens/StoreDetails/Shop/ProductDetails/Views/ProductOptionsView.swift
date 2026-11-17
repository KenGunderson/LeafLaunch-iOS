import SwiftUI

struct ProductOptionsView: View {

    @Environment(\.style) private var style

    let product: Product
    var contentInset: CGFloat = 0

    var body: some View {

        LLSection(
            title: String(localized: "Size & Pricing"),
            headingHorizontalPadding: .custom(self.contentInset)
        ) {

            if self.product.variants.isEmpty {

                Text(String(localized: "No Pricing Options Available"))
                    .runeFont(with: .BODY_2)
                    .runeTextColor(.body)
                    .runePadding(.horizontal, .custom(self.contentInset))

            } else {

                pricingOptions()

            }

        }

    }

    @ContentBuilder
    private func pricingOptions() -> some View {

        if self.product.variants.count <= 3 {

            HStack(
                alignment: .top,
                spacing: self.style.spacing(LLSpacing.groupedContent)
            ) {

                ForEach(self.product.variants, id: \.id) { variant in
                    option(variant)
                }

            }
            .fixedSize(
                horizontal: false,
                vertical: true
            )
            .runePadding(.horizontal, .custom(self.contentInset))

        } else {

            pricingRail()

        }

    }

    @ContentBuilder
    private func pricingRail() -> some View {

        ScrollView(
            .horizontal,
            showsIndicators: false
        ) {

            HStack(
                alignment: .top,
                spacing: self.style.spacing(LLSpacing.groupedContent)
            ) {

                ForEach(self.product.variants, id: \.id) { variant in

                    option(variant)
                        .containerRelativeFrame(
                            .horizontal,
                            count: 3,
                            spacing: self.style.spacing(LLSpacing.groupedContent)
                        )

                }

            }
            .fixedSize(
                horizontal: false,
                vertical: true
            )
            .runePadding(.vertical, LLSpacing.metadata)

        }
        .safeAreaPadding(
            .horizontal,
            self.contentInset
        )

    }

    @ContentBuilder
    private func option(_ variant: ProductPricing) -> some View {

        RNOutlineCardView(
            verticalPadding: .small2,
            horizontalPadding: .small2,
            backgroundStyle: .background(.secondary),
            outlineColor: .background(.border),
            outlineWidth: 1,
            cornerRadius: .medium
        ) {

            VStack(
                alignment: .leading,
                spacing: self.style.spacing(LLSpacing.groupedContent)
            ) {

                optionName(variant)
                price(variant)
                availability(variant)

            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

        }
        .frame(maxWidth: .infinity)
        .frame(maxHeight: .infinity, alignment: .top)

    }

    @ContentBuilder
    private func optionName(_ variant: ProductPricing) -> some View {

        Text(variant.name)
            .runeFont(with: .BODY_2)
            .runeTextColor(.title)
            .fixedSize(
                horizontal: false,
                vertical: true
            )

    }

    @ContentBuilder
    private func availability(_ variant: ProductPricing) -> some View {

        let isAvailable = self.product.status == .published && variant.availability == .available

        Text(isAvailable ? String(localized: "Available") : String(localized: "Sold Out"))
            .runeFont(with: .BODY_2)
            .foregroundStyle(isAvailable ? RNColorSource.foreground(.primary) : RNColorSource.text(.body))
            .fixedSize(
                horizontal: false,
                vertical: true
            )

    }

    @ContentBuilder
    private func price(_ variant: ProductPricing) -> some View {

        VStack(
            alignment: .leading,
            spacing: self.style.spacing(LLSpacing.metadata)
        ) {

            if let price = variant.displayPrice {

                Text(price.formatted(.currency(code: self.product.currencyCode)))
                    .runeFont(with: .TITLE_6)
                    .runeTextColor(.title)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )

            } else {

                Text(String(localized: "Price Unavailable"))
                    .runeFont(with: .BODY_1)
                    .runeTextColor(.body)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )

            }

        }

    }

}

#Preview {

    if let product = MockCustomerModels.products.first {

        ProductOptionsView(product: product)
            .runePadding(LLSpacing.pageInset)
            .withMockPreviews()

    }

}
