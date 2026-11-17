import SwiftUI

struct CatalogCategoryFilters: View {

    @Environment(\.style) private var style
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

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

    private var selectionAnimation: Animation? {
        self.reduceMotion ? nil : .bouncy
    }

    var body: some View {

        VStack(spacing: self.style.spacing(LLSpacing.none)) {

            if !self.categories.isEmpty {

                categoryContent()

            }

        }

    }

    @ContentBuilder
    private func categoryContent() -> some View {

        VStack(spacing: self.style.spacing(LLSpacing.none)) {

            categoryRail()

            if let category = self.selectedCategory, category.subcategories.count > 1 {

                subcategoryRail(category: category)
                    .id(category.id)
                    .runePadding(.top, LLSpacing.metadata)
                    .transition(AnyTransition(.blurReplace))

            }

        }
        .animation(
            self.selectionAnimation,
            value: (self.selectedCategory?.subcategories.count ?? 0) > 1
        )
        .animation(
            self.selectionAnimation,
            value: self.selectedCategoryId
        )
        .animation(
            self.selectionAnimation,
            value: self.selectedSubcategoryId
        )

    }

    @ContentBuilder
    private func categoryRail() -> some View {

        ScrollView(.horizontal) {

            HStack(spacing: self.style.spacing(LLSpacing.listRow)) {

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
        .safeAreaPadding(
            .horizontal,
            self.style.spacing(LLSpacing.listRow)
        )

    }

    @ContentBuilder
    private func subcategoryRail(category: ProductCategory) -> some View {

        ScrollView(.horizontal) {

            HStack(spacing: self.style.spacing(LLSpacing.listRow)) {

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
        .safeAreaPadding(
            .horizontal,
            self.style.spacing(LLSpacing.listRow)
        )

    }

    @ContentBuilder
    private func categoryTab(_ category: ProductCategory) -> some View {

        CatalogCategoryTab(
            title: category.name,
            isSelected: self.selectedCategoryId == category.id,
            underlineId: category.id,
            underlineNamespace: self.categoryUnderlineNamespace
        ) {

            withAnimation(self.selectionAnimation) {
                self.onCategorySelected(category.id)
            }

        }

    }

    @ContentBuilder
    private func subcategoryTab(_ subcategory: ProductSubcategory) -> some View {

        CatalogCategoryTab(
            title: subcategory.name,
            isSelected: self.selectedSubcategoryId == subcategory.id,
            underlineId: subcategory.id,
            underlineNamespace: self.subcategoryUnderlineNamespace
        ) {

            withAnimation(self.selectionAnimation) {
                self.onSubcategorySelected(subcategory.id)
            }

        }

    }

    @ContentBuilder
    private func selectionUnderline(selectedId: String?, namespace: Namespace.ID) -> some View {

        if let selectedId {

            Capsule()
                .runeFill(RNColorSource.palette(.link))
                .frame(height: 3)
                .matchedGeometryEffect(
                    id: selectedId,
                    in: namespace,
                    properties: .frame,
                    isSource: false
                )
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
