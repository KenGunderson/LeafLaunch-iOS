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

        VStack(alignment: .leading, spacing: self.style.spacing(.small2)) {

            if self.images.isEmpty {

                ProductImageView(url: nil)
                    .aspectRatio(1, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: self.style.radius(.medium2)))
                    .appBorder(cornerRadius: .medium2, lineWidth: 1, outerBorder: false)

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

    @ViewBuilder
    private func pages() -> some View {

        TabView(selection: self.selection) {

            ForEach(self.images) { image in

                imagePage(image)

            }

        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .aspectRatio(1, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: self.style.radius(.medium2)))
        .appBorder(cornerRadius: .medium2, lineWidth: 1, outerBorder: false)
        .animation(.bouncy, value: self.selectedImageId)

    }

    @ViewBuilder
    private func thumbnails() -> some View {

        ScrollView(.horizontal) {

            HStack(spacing: self.style.spacing(.small)) {

                ForEach(self.images) { image in

                    thumbnail(image)

                }

            }

        }
        .scrollIndicators(.hidden)

    }

    @ViewBuilder
    private func thumbnail(_ image: ProductMedia) -> some View {

        let isSelected = self.selection.wrappedValue == image.id

        ProductImageView(
            url: image.url,
            showsPlaceholderLabel: false
        )
        .frame(width: 72, height: 72)
        .clipShape(RoundedRectangle(cornerRadius: self.style.radius(.medium)))
        .overlay {

            RoundedRectangle(cornerRadius: self.style.radius(.medium))
                .strokeBorder(
                    isSelected
                        ? self.style.palette(.link)
                        : self.style.background(.border),
                    lineWidth: isSelected ? 2 : 1
                )

        }
        .asButton {
            self.selectedImageId = image.id
        }

    }

    @ViewBuilder
    private func imagePage(_ image: ProductMedia) -> some View {

        ProductImageView(url: image.url)
            .tag(image.id)

    }

}

#Preview {

    if let product = MockCustomerModels.products.first {

        ScrollView {

            ProductGalleryView(product: product)
            .padding(.medium)

        }
        .withMockPreviews()

    }

}
