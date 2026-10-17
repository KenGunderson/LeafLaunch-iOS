import SwiftUI

struct StoreMarketingImage: View {

    @Environment(\.style) private var style

    let url: URL?
    let placeholder: ImageResource

    var body: some View {

        Rectangle()
            .fill(self.style.background(.tertiary))
            .overlay {

                GeometryReader { geometry in

                    image()
                        .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
                        .clipped()

                }

            }
            .clipped()

    }

    @ViewBuilder
    private func image() -> some View {

        if let url = self.url {

            ImageSource.remote(
                url: url,
                contentMode: .fill,
                placeholder: AnyView(fallbackImage())
            )
            .view()

        } else {

            fallbackImage()

        }

    }

    @ViewBuilder
    private func fallbackImage() -> some View {

        ImageSource.image(self.placeholder)
            .view()
            .scaledToFill()

    }

}

#Preview {

    StoreMarketingImage(
        url: nil,
        placeholder: ImageResource(name: "StoreEventFallback", bundle: .main)
    )
        .aspectRatio(1.6, contentMode: .fit)
        .cornerRadius(.large)
        .padding(.medium)
        .withMockPreviews()

}
