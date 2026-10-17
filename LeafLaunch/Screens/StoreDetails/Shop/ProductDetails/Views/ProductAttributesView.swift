import SwiftUI

struct ProductAttributesView: View {

    @Environment(\.style) private var style

    let attributes: [ProductAttribute]

    var body: some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.medium)) {

            CommerceSectionHeader(title: String(localized: "Product Details"))

            CommerceSurface {
                attributeRows()
            }

        }

    }

    @ViewBuilder
    private func attributeRows() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.small2)) {

            ForEach(self.attributes, id: \.id) { attribute in

                if attribute.id != self.attributes.first?.id {
                    Divider().overlay(self.style.background(.border))
                }

                attributeRow(attribute)

            }

        }

    }

    @ViewBuilder
    private func attributeRow(_ attribute: ProductAttribute) -> some View {

        LabeledContent {

            Text(attribute.displayValue)
                .appFont(with: .BODY_2)
                .foregroundStyle(.text(.title))
                .multilineTextAlignment(.trailing)
                .fixedSize(horizontal: false, vertical: true)
                .textSelection(.enabled)

        } label: {

            Text(attribute.name)
                .appFont(with: .NOTE_1)
                .foregroundStyle(.text(.body))
                .fixedSize(horizontal: false, vertical: true)

        }

    }

}

#Preview {

    ProductAttributesView(attributes: MockCustomerModels.previewProductAttributes)
        .padding(.medium)
        .withMockPreviews()

}
