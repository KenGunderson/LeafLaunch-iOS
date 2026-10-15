import SwiftUI

struct ProductImageView: View {

    @Environment(\.style) private var style

    @State private var failedImageURL: URL?

    let url: URL?
    var isLoading: Bool = false
    var isUnavailable: Bool = false
    var showsPlaceholderLabel: Bool = true

    var body: some View {

        self.style.background(.quinary).view()
            .overlay {

                if let url = self.url {

                    ImageSource.remote(
                        url: url,
                        contentMode: .fill,
                        placeholder: AnyView(placeholder(isLoading: self.failedImageURL != url)),
                        onSuccess: { _ in self.failedImageURL = nil },
                        onError: { _ in self.failedImageURL = url }
                    )
                    .view()

                } else {

                    placeholder(isLoading: self.isLoading)

                }

            }
            .clipped()
            .onChange(of: self.url) { _, _ in self.failedImageURL = nil }

    }

    private func placeholder(isLoading: Bool) -> some View {

        VStack(spacing: self.style.spacing(.small)) {

            if isLoading {

                ProgressView()
                    .tint(self.style.foreground(.primary).resolvedColor(style: self.style))

            } else {

                ImageSource.systemImage("photo")
                    .view(shouldResize: false)
                    .appFont(with: .HEADER_3)

            }

            if self.showsPlaceholderLabel {

                Text(
                    isLoading
                        ? String(localized: "Loading image…")
                        : self.isUnavailable || self.failedImageURL != nil
                            ? String(localized: "Image unavailable")
                            : String(localized: "No product image")
                )
                    .appFont(with: .NOTE_1)
                    .multilineTextAlignment(.center)

            }

        }
        .foregroundStyle(.text(.body))
        .padding(.small)
        .frame(maxWidth: .infinity, maxHeight: .infinity)

    }

}

#Preview("Product image") {

    if let product = MockCustomerModels.products.first {

        ProductImageView(
            url: MockCustomerModels.previewCoverImageURLs[product.id]
        )
        .aspectRatio(1, contentMode: .fit)
        .padding(.medium)
        .withMockPreviews()

    }

}

#Preview("Loading") {

    ProductImageView(url: nil, isLoading: true)
        .aspectRatio(1, contentMode: .fit)
        .padding(.medium)
        .withMockPreviews()

}

#Preview("Unavailable") {

    ProductImageView(url: nil, isUnavailable: true)
        .aspectRatio(1, contentMode: .fit)
        .padding(.medium)
        .withMockPreviews()

}
