import SwiftUI

struct CatalogCategoryFilters: View {

    @Environment(\.style) private var style

    let categories: [ProductCategory]
    let selectedCategoryId: String?
    let selectedSubcategoryId: String?
    let onCategorySelected: (String?) -> Void
    let onSubcategorySelected: (String?) -> Void

    private var selectedCategory: ProductCategory? {
        self.categories.first { $0.id == self.selectedCategoryId }
    }

    var body: some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.extraSmall)) {

            categoryRail()

            if let category = self.selectedCategory, !category.subcategories.isEmpty {

                subcategoryRail(category: category)
                    .id(category.id)
                    .transition(AnyTransition(.blurReplace))

            }

        }
        .animation(.bouncy, value: self.selectedCategoryId)
        .animation(.bouncy, value: self.selectedSubcategoryId)

    }

    @ViewBuilder
    private func categoryRail() -> some View {

        ScrollView(.horizontal) {

            HStack(spacing: self.style.spacing(.small)) {

                ForEach(self.categories) { category in
                    categoryPill(category)
                }

            }
            .padding(.vertical, .extraSmall)

        }
        .scrollIndicators(.hidden)
        .safeAreaPadding(.horizontal, self.style.spacing(.medium))

    }

    @ViewBuilder
    private func subcategoryRail(category: ProductCategory) -> some View {

        ScrollView(.horizontal) {

            HStack(spacing: self.style.spacing(.small)) {

                ForEach(category.subcategories) { subcategory in
                    subcategoryPill(subcategory)
                }

            }
            .padding(.vertical, .extraSmall)

        }
        .scrollIndicators(.hidden)
        .safeAreaPadding(.horizontal, self.style.spacing(.medium))

    }

    @ViewBuilder
    private func categoryPill(_ category: ProductCategory) -> some View {

        CatalogFilterPill(
            title: category.name,
            imageURL: category.imageURL,
            isSelected: self.selectedCategoryId == category.id
        ) {
            self.onCategorySelected(category.id)
        }

    }

    @ViewBuilder
    private func subcategoryPill(_ subcategory: ProductSubcategory) -> some View {

        CatalogFilterPill(
            title: subcategory.name,
            isSelected: self.selectedSubcategoryId == subcategory.id
        ) {
            self.onSubcategorySelected(subcategory.id)
        }

    }

}

#Preview {

    @Previewable @State var selectedCategoryId = MockCustomerModels.categories.first?.id
    @Previewable @State var selectedSubcategoryId = MockCustomerModels.categories.first?.subcategories.first?.id

    CatalogCategoryFilters(
        categories: MockCustomerModels.categories,
        selectedCategoryId: selectedCategoryId,
        selectedSubcategoryId: selectedSubcategoryId,
        onCategorySelected: { categoryId in

            selectedCategoryId = categoryId
            selectedSubcategoryId = MockCustomerModels.categories.first { $0.id == categoryId }?.subcategories.first?.id

        },
        onSubcategorySelected: { selectedSubcategoryId = $0 }
    )
    .withMockPreviews()

}
