import SwiftUI

struct ProductAttributesView: View {

    @Environment(\.style) private var style

    let attributes: [ProductAttribute]

    var body: some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.medium)) {

            CommerceSectionHeader(title: String(localized: "Product details"))

            CommerceSurface {

                VStack(alignment: .leading, spacing: self.style.spacing(.medium)) {

                    ForEach(self.attributes, id: \.id) { attribute in

                        if attribute.id != self.attributes.first?.id {
                            Divider()
                        }

                        VStack(alignment: .leading, spacing: self.style.spacing(.extraSmall)) {

                            Text(attribute.name)
                                .appFont(with: .NOTE_1)
                                .foregroundStyle(.text(.body))

                            Text(attribute.displayValue)
                                .appFont(with: .BODY_2)
                                .foregroundStyle(.text(.title))
                                .textSelection(.enabled)

                        }

                    }

                }

            }

        }

    }

}

#Preview {

    ProductAttributesView(attributes: MockCustomerModels.previewProductAttributes)
        .padding(.medium)
        .withMockPreviews()

}
