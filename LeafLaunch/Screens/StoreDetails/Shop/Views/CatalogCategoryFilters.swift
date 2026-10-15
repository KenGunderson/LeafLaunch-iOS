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

        VStack(alignment: .leading, spacing: self.style.spacing(.small2)) {

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

    private func categoryRail() -> some View {

        ScrollView(.horizontal) {

            HStack(spacing: self.style.spacing(.small)) {

                CatalogFilterPill(title: String(localized: "All"), isSelected: self.selectedCategoryId == nil) {
                    self.onCategorySelected(nil)
                }

                ForEach(self.categories) { category in

                    CatalogFilterPill(title: category.name, isSelected: self.selectedCategoryId == category.id) {
                        self.onCategorySelected(category.id)
                    }

                }

            }
            .padding(.vertical, .extraSmall)

        }
        .scrollIndicators(.hidden)

    }

    private func subcategoryRail(category: ProductCategory) -> some View {

        ScrollView(.horizontal) {

            HStack(spacing: self.style.spacing(.small)) {

                CatalogFilterPill(
                    title: String(localized: "All \(category.name)"),
                    isSelected: self.selectedSubcategoryId == nil
                ) {
                    self.onSubcategorySelected(nil)
                }

                ForEach(category.subcategories) { subcategory in

                    CatalogFilterPill(
                        title: subcategory.name,
                        isSelected: self.selectedSubcategoryId == subcategory.id
                    ) {
                        self.onSubcategorySelected(subcategory.id)
                    }

                }

            }
            .padding(.vertical, .extraSmall)

        }
        .scrollIndicators(.hidden)

    }

}

#Preview {

    @Previewable @State var selectedCategoryId = MockCustomerModels.categories.first?.id
    @Previewable @State var selectedSubcategoryId: String?

    CatalogCategoryFilters(
        categories: MockCustomerModels.categories,
        selectedCategoryId: selectedCategoryId,
        selectedSubcategoryId: selectedSubcategoryId,
        onCategorySelected: { categoryId in

            selectedCategoryId = categoryId
            selectedSubcategoryId = nil

        },
        onSubcategorySelected: { selectedSubcategoryId = $0 }
    )
    .padding(.medium)
    .withMockPreviews()

}
