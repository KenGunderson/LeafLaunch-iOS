import SwiftUI

struct StoreMarketingImage: View {

    @Environment(\.style) private var style

    let url: URL?
    let placeholder: ImageResource

    var body: some View {

        Rectangle()
            .runeFill(RNColorSource.background(.tertiary))
            .overlay {

                GeometryReader { geometry in

                    image()
                        .frame(
                            width: geometry.size.width,
                            height: geometry.size.height,
                            alignment: .center
                        )
                        .clipped()

                }

            }
            .clipped()

    }

    @ContentBuilder
    private func image() -> some View {

        if let url = self.url {

            RNImageSource.remote(
                url: url,
                contentMode: .fill,
                placeholder: AnyView(fallbackImage())
            )
            .view()

        } else {

            fallbackImage()

        }

    }

    @ContentBuilder
    private func fallbackImage() -> some View {

        RNImageSource.image(self.placeholder)
            .view()
            .scaledToFill()

    }

}

#Preview {

    StoreMarketingImage(
        url: nil,
        placeholder: ImageResource(
            name: "StoreEventFallback",
            bundle: .main
        )
    )
        .aspectRatio(
            1.6,
            contentMode: .fit
        )
        .runeCornerRadius(.large)
        .runePadding(LLSpacing.pageInset)
        .withMockPreviews()

}
