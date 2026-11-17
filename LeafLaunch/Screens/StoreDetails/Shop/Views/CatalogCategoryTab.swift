import SwiftUI

struct CatalogCategoryTab: View {

    @Environment(\.style) private var style

    let title: String
    let isSelected: Bool
    let underlineId: String
    let underlineNamespace: Namespace.ID
    let action: () -> Void

    var body: some View {

        Text(self.title)
            .runeFont(with: .TITLE_3)
            .runePadding(.horizontal, LLSpacing.metadata)
            .frame(minHeight: 44)
            .runePadding(.bottom, .custom(3))
            .foregroundStyle(self.isSelected ? RNColorSource.palette(.link) : RNColorSource.text(.body))
            .fixedSize(
                horizontal: true,
                vertical: false
            )
            .contentShape(Rectangle())
            .runeAsButton(action: self.action)
            .overlay(alignment: .bottom) {

                Color.clear
                    .frame(height: 3)
                    .matchedGeometryEffect(
                        id: self.underlineId,
                        in: self.underlineNamespace,
                        properties: .frame,
                        isSource: true
                    )
                    .allowsHitTesting(false)

            }

    }

}

#Preview {

    @Previewable @State var selectedId = "flower"
    @Previewable @Namespace var underlineNamespace

    HStack(spacing: RNStyle.shared.spacing(LLSpacing.groupedContent)) {

        CatalogCategoryTab(
            title: "Edibles",
            isSelected: selectedId == "edibles",
            underlineId: "edibles",
            underlineNamespace: underlineNamespace
        ) {
            withAnimation(.bouncy) { selectedId = "edibles" }
        }

        CatalogCategoryTab(
            title: "Flower",
            isSelected: selectedId == "flower",
            underlineId: "flower",
            underlineNamespace: underlineNamespace
        ) {
            withAnimation(.bouncy) { selectedId = "flower" }
        }

    }
    .overlay(alignment: .bottomLeading) {

        Capsule()
            .fill(.tint)
            .frame(height: 3)
            .matchedGeometryEffect(
                id: selectedId,
                in: underlineNamespace,
                properties: .frame,
                isSource: false
            )
            .allowsHitTesting(false)

    }
    .runePadding(LLSpacing.pageInset)
    .withMockPreviews()

}
