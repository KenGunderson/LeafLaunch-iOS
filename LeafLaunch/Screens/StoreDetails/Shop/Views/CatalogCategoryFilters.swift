import SwiftUI

struct CatalogCategoryFilters: View {

    @Environment(\.style) private var style

    @Namespace private var categoryUnderlineNamespace
    @Namespace private var subcategoryUnderlineNamespace

    let categories: [ProductCategory]
    let selectedCategoryId: String?
    let selectedSubcategoryId: String?
    let onCategorySelected: (String?) -> Void
    let onSubcategorySelected: (String?) -> Void

    private var selectedCategory: ProductCategory? {
        self.categories.first { $0.id == self.selectedCategoryId }
    }

    var body: some View {

        VStack(spacing: 0) {

            categoryRail()

            if let category = self.selectedCategory, !category.subcategories.isEmpty {

                subcategoryRail(category: category)
                    .padding(.top, .extraSmall)
                    .transition(AnyTransition(.blurReplace))

            }

            Rectangle()
                .fill(self.style.background(.border))
                .frame(height: 1)

        }
        .animation(.bouncy, value: self.selectedCategoryId)
        .animation(.bouncy, value: self.selectedSubcategoryId)

    }

    @ViewBuilder
    private func categoryRail() -> some View {

        ScrollView(.horizontal) {

            HStack(spacing: self.style.spacing(.medium)) {

                ForEach(self.categories) { category in
                    categoryTab(category)
                }

            }
            .overlay(alignment: .bottomLeading) {

                selectionUnderline(
                    selectedId: self.selectedCategoryId,
                    namespace: self.categoryUnderlineNamespace
                )

            }

        }
        .scrollIndicators(.hidden)
        .safeAreaPadding(.horizontal, self.style.spacing(.medium))

    }

    @ViewBuilder
    private func subcategoryRail(category: ProductCategory) -> some View {

        ScrollView(.horizontal) {

            HStack(spacing: self.style.spacing(.medium)) {

                ForEach(category.subcategories) { subcategory in
                    subcategoryTab(subcategory)
                }

            }
            .overlay(alignment: .bottomLeading) {

                selectionUnderline(
                    selectedId: self.selectedSubcategoryId,
                    namespace: self.subcategoryUnderlineNamespace
                )

            }

        }
        .scrollIndicators(.hidden)
        .safeAreaPadding(.horizontal, self.style.spacing(.medium))

    }

    @ViewBuilder
    private func categoryTab(_ category: ProductCategory) -> some View {

        CatalogCategoryTab(
            title: category.name,
            isSelected: self.selectedCategoryId == category.id,
            underlineId: category.id,
            underlineNamespace: self.categoryUnderlineNamespace
        ) {

            withAnimation(.bouncy) {
                self.onCategorySelected(category.id)
            }

        }

    }

    @ViewBuilder
    private func subcategoryTab(_ subcategory: ProductSubcategory) -> some View {

        CatalogCategoryTab(
            title: subcategory.name,
            isSelected: self.selectedSubcategoryId == subcategory.id,
            underlineId: subcategory.id,
            underlineNamespace: self.subcategoryUnderlineNamespace
        ) {

            withAnimation(.bouncy) {
                self.onSubcategorySelected(subcategory.id)
            }

        }

    }

    @ViewBuilder
    private func selectionUnderline(selectedId: String?, namespace: Namespace.ID) -> some View {

        if let selectedId {

            Capsule()
                .fill(self.style.palette(.link))
                .frame(height: 3)
                .matchedGeometryEffect(id: selectedId, in: namespace, properties: .frame, isSource: false)
                .allowsHitTesting(false)

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
        onCategorySelected: {

            selectedCategoryId = $0
            selectedSubcategoryId = MockCustomerModels.categories.first { $0.id == selectedCategoryId }?.subcategories.first?.id

        },
        onSubcategorySelected: { selectedSubcategoryId = $0 }
    )
    .withMockPreviews()

}
