import SwiftUI

struct ProductDetailsSummaryView: View {

    @Environment(\.style) private var style

    let product: Product

    var body: some View {

        VStack(
            alignment: .leading,
            spacing: self.style.spacing(LLSpacing.metadata)
        ) {

            Text(self.product.displayName)
                .runeFont(with: .TITLE_7)
                .runeTextColor(.title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )

            categoryNames()

        }
        .frame(maxWidth: .infinity, alignment: .leading)

    }

    @ContentBuilder
    private func categoryNames() -> some View {

        let categories = [self.product.category?.name, self.product.subcategory?.name]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: " · ")

        if !categories.isEmpty {

            Text(categories)
                .runeFont(with: .BODY_3)
                .runeTextColor(.body)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )

        }

    }

}

#Preview {

    if let product = MockCustomerModels.products.first {

        ProductDetailsSummaryView(product: product)
            .runePadding(LLSpacing.pageInset)
            .withMockPreviews()

    }

}
