import SwiftUI

struct ProductGalleryView: View {

    @Environment(\.style) private var style

    @State private var selectedImageId: String = ""

    let product: Product

    private var images: [ProductMedia] { self.product.activeImages }

    private var selectedIndex: Int {
        self.images.firstIndex { $0.id == self.selectedImageId } ?? 0
    }

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
                    .clipShape(RoundedRectangle(cornerRadius: self.style.radius(.large)))

            } else {

                pages()

                if self.images.count > 1 {
                    thumbnails()
                }

                imageCaption()

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
        .clipShape(RoundedRectangle(cornerRadius: self.style.radius(.large)))
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
    private func imageCaption() -> some View {

        HStack(alignment: .top, spacing: self.style.spacing(.small)) {

            if self.images.indices.contains(self.selectedIndex),
               let caption = self.images[self.selectedIndex].altText,
               !caption.isEmpty {

                Text(caption)
                    .frame(maxWidth: .infinity, alignment: .leading)

            } else {
                Spacer(minLength: 0)
            }

            Text(String(localized: "Image \(self.selectedIndex + 1) of \(self.images.count)"))
                .fixedSize(horizontal: true, vertical: false)

        }
        .appFont(with: .NOTE_1)
        .foregroundStyle(.text(.body))

    }

    @ViewBuilder
    private func thumbnail(_ image: ProductMedia) -> some View {

        let index = self.images.firstIndex { $0.id == image.id } ?? 0

        ProductImageView(
            url: image.url,
            showsPlaceholderLabel: false
        )
        .frame(width: 64, height: 64)
        .clipShape(RoundedRectangle(cornerRadius: self.style.radius(.medium)))
        .overlay {

            RoundedRectangle(cornerRadius: self.style.radius(.medium))
                .strokeBorder(
                    self.selectedIndex == index
                        ? self.style.foreground(.primary)
                        : self.style.background(.border),
                    lineWidth: self.selectedIndex == index ? 2 : 1
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
