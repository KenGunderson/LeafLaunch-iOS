import SwiftUI

struct ProductImageView: View {

    @Environment(\.style) private var style

    @State private var failedImageURL: URL?

    let url: URL?
    var isLoading: Bool = false
    var isUnavailable: Bool = false
    var showsPlaceholderLabel: Bool = true

    var body: some View {

        RNColorSource.background(.quinary).view()
            .overlay {

                if let url = self.url {

                    RNImageSource.remote(
                        url: url,
                        contentMode: .fill,
                        placeholder: AnyView(placeholder(isLoading: self.failedImageURL != url)),
                        onSuccess: { _ in self.failedImageURL = nil },
                        onFailure: { _ in self.failedImageURL = url }
                    )
                    .view()

                } else {

                    placeholder(isLoading: self.isLoading)

                }

            }
            .clipped()
            .onChange(of: self.url) { _, _ in self.failedImageURL = nil }

    }

    @ContentBuilder
    private func placeholder(isLoading: Bool) -> some View {

        VStack(spacing: self.style.spacing(LLSpacing.groupedContent)) {

            if isLoading {

                ProgressView()
                    .runeTint(.primary)

            } else {

                RNImageSource.systemImage("photo")
                    .view(shouldResize: false)
                    .runeFont(with: .HEADER_3)

            }

            if self.showsPlaceholderLabel {

                Text(
                    isLoading
                        ? String(localized: "Loading Image…")
                        : self.isUnavailable || self.failedImageURL != nil
                            ? String(localized: "Image Unavailable")
                            : String(localized: "No Product Image")
                )
                    .runeFont(with: .NOTE_1)
                    .multilineTextAlignment(.center)

            }

        }
        .runeTextColor(.body)
        .runePadding(LLSpacing.groupedContent)
        .frame(maxWidth: .infinity, maxHeight: .infinity)

    }

}

#Preview("Product image") {

    if let product = MockCustomerModels.products.first {

        ProductImageView(
            url: product.activeImages.first?.url
        )
        .aspectRatio(
            1,
            contentMode: .fit
        )
        .runePadding(LLSpacing.pageInset)
        .withMockPreviews()

    }

}

#Preview("Loading") {

    ProductImageView(
        url: nil,
        isLoading: true
    )
        .aspectRatio(
            1,
            contentMode: .fit
        )
        .runePadding(LLSpacing.pageInset)
        .withMockPreviews()

}

#Preview("Unavailable") {

    ProductImageView(
        url: nil,
        isUnavailable: true
    )
        .aspectRatio(
            1,
            contentMode: .fit
        )
        .runePadding(LLSpacing.pageInset)
        .withMockPreviews()

}
