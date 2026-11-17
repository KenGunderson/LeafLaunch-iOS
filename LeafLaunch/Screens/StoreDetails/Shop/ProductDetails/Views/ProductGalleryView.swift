import SwiftUI

struct ProductGalleryView: View {

    @Environment(\.style) private var style

    @State private var selectedImageId: String = ""

    let product: Product

    private var images: [ProductMedia] { self.product.activeImages }

    private var selection: Binding<String> {

        Binding(
            get: {

                if self.images.contains(where: { $0.id == self.selectedImageId }) {
                    return self.selectedImageId
                }

                return self.images.first?.id ?? ""

            },
            set: { self.selectedImageId = $0 }
        )

    }

    var body: some View {

        VStack(
            alignment: .leading,
            spacing: self.style.spacing(LLSpacing.cardContent)
        ) {

            if self.images.isEmpty {

                ProductImageView(url: nil)
                    .aspectRatio(
                        1,
                        contentMode: .fit
                    )
                    .runeCornerRadius(.medium2)
                    .runeBorder(
                        cornerRadius: .medium2,
                        lineWidth: 1,
                        outerBorder: false
                    )

            } else {

                pages()

                if self.images.count > 1 {
                    thumbnails()
                }

            }

        }
        .onChange(of: self.images.map(\.id)) { _, _ in

            guard !self.images.contains(where: { $0.id == self.selectedImageId }) else { return }
            self.selectedImageId = self.images.first?.id ?? ""

        }

    }

    @ContentBuilder
    private func pages() -> some View {

        TabView(selection: self.selection) {

            ForEach(self.images) { image in

                imagePage(image)

            }

        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .aspectRatio(
            1,
            contentMode: .fit
        )
        .runeCornerRadius(.medium2)
        .runeBorder(
            cornerRadius: .medium2,
            lineWidth: 1,
            outerBorder: false
        )
        .animation(
            .bouncy,
            value: self.selectedImageId
        )

    }

    @ContentBuilder
    private func thumbnails() -> some View {

        ScrollView(.horizontal) {

            HStack(spacing: self.style.spacing(LLSpacing.groupedContent)) {

                ForEach(self.images) { image in

                    thumbnail(image)

                }

            }

        }
        .scrollIndicators(.hidden)

    }

    @ContentBuilder
    private func thumbnail(_ image: ProductMedia) -> some View {

        let isSelected = self.selection.wrappedValue == image.id

        ProductImageView(
            url: image.url,
            showsPlaceholderLabel: false
        )
        .frame(
            width: 72,
            height: 72
        )
        .runeCornerRadius(.medium)
        .overlay {

            RoundedRectangle(cornerRadius: self.style.radius(.medium))
                .strokeBorder(
                    isSelected
                        ? RNColorSource.palette(.link)
                        : RNColorSource.background(.border),
                    lineWidth: isSelected ? 2 : 1
                )

        }
        .runeAsButton {
            self.selectedImageId = image.id
        }

    }

    @ContentBuilder
    private func imagePage(_ image: ProductMedia) -> some View {

        ProductImageView(url: image.url)
            .tag(image.id)

    }

}

#Preview {

    if let product = MockCustomerModels.products.first {

        ScrollView {

            ProductGalleryView(product: product)
            .runePadding(LLSpacing.pageInset)

        }
        .withMockPreviews()

    }

}
