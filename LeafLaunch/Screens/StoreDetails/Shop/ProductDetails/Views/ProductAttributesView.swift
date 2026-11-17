import SwiftUI

struct ProductAttributesView: View {

    @Environment(\.style) private var style

    let attributes: [ProductAttribute]

    var body: some View {

        LLSection(title: String(localized: "Product Details")) {

            LLAppCardView(cornerRadius: .medium2) {
                attributeRows()
            }
            .frame(maxWidth: .infinity)

        }

    }

    @ContentBuilder
    private func attributeRows() -> some View {

        VStack(
            alignment: .leading,
            spacing: self.style.spacing(LLSpacing.groupedContent)
        ) {

            ForEach(self.attributes, id: \.id) { attribute in

                if attribute.id != self.attributes.first?.id {
                    LLDivider()
                }

                attributeRow(attribute)

            }

        }

    }

    @ContentBuilder
    private func attributeRow(_ attribute: ProductAttribute) -> some View {

        LabeledContent {

            Text(attribute.displayValue)
                .runeFont(with: .BODY_2)
                .runeTextColor(.title)
                .multilineTextAlignment(.trailing)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )
                .textSelection(.enabled)

        } label: {

            Text(attribute.name)
                .runeFont(with: .BODY_2)
                .runeTextColor(.body)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )

        }

    }

}

#Preview {

    ProductAttributesView(attributes: MockCustomerModels.previewProductAttributes)
        .runePadding(LLSpacing.pageInset)
        .withMockPreviews()

}
