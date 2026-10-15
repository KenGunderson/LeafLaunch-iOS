import SwiftUI

struct ProductImageView: View {

    @Environment(\.style) private var style

    @State private var failedImageURL: URL?

    let url: URL?
    let accessibilityLabel: String
    var isLoading: Bool = false
    var isUnavailable: Bool = false
    var showsPlaceholderLabel: Bool = true

    var body: some View {

        ZStack {

            self.style.background(.quinary).view()

            if let url = self.url {

                ImageSource.remote(
                    url: url,
                    contentMode: .fit,
                    placeholder: AnyView(placeholder(isLoading: self.failedImageURL != url)),
                    onSuccess: { _ in self.failedImageURL = nil },
                    onError: { _ in self.failedImageURL = url }
                )
                .view()
                .accessibilityLabel(
                    self.failedImageURL == url
                        ? String(localized: "Image unavailable for \(self.accessibilityLabel)")
                        : self.accessibilityLabel
                )

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
        .accessibilityElement(children: .combine)

    }

}

#Preview("Product image") {

    if let product = MockCustomerModels.products.first {

        ProductImageView(
            url: MockCustomerModels.previewCoverImageURLs[product.id],
            accessibilityLabel: product.displayName
        )
        .aspectRatio(1, contentMode: .fit)
        .padding(.medium)
        .withMockPreviews()

    }

}

#Preview("Loading") {

    ProductImageView(url: nil, accessibilityLabel: "Product", isLoading: true)
        .aspectRatio(1, contentMode: .fit)
        .padding(.medium)
        .withMockPreviews()

}

#Preview("Unavailable") {

    ProductImageView(url: nil, accessibilityLabel: "Product", isUnavailable: true)
        .aspectRatio(1, contentMode: .fit)
        .padding(.medium)
        .withMockPreviews()

}
