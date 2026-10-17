import SwiftUI

struct ProductDetailsSummaryView: View {

    @Environment(\.style) private var style

    let product: Product

    var body: some View {

        HStack(alignment: .top, spacing: self.style.spacing(.small)) {

            categoryImage()

            VStack(alignment: .leading, spacing: self.style.spacing(.extraSmall)) {

                Text(self.product.displayName)
                    .appFont(with: .TITLE_3)
                    .foregroundStyle(.text(.title))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)

                categoryNames()

            }

        }
        .frame(maxWidth: .infinity, alignment: .leading)

    }

    @ViewBuilder
    private func categoryImage() -> some View {

        if let imageURL = self.product.category?.imageURL {

            ProductCategoryImageView(url: imageURL)
                .frame(width: self.style.spacing(.large), height: self.style.spacing(.large))

        }

    }

    @ViewBuilder
    private func categoryNames() -> some View {

        let categories = [self.product.category?.name, self.product.subcategory?.name]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: " · ")

        if !categories.isEmpty {

            Text(categories)
                .appFont(with: .NOTE_1)
                .foregroundStyle(.text(.body))
                .fixedSize(horizontal: false, vertical: true)

        }

    }

}

#Preview {

    if let product = MockCustomerModels.products.first {

        ProductDetailsSummaryView(product: product)
            .padding(.medium)
            .withMockPreviews()

    }

}
