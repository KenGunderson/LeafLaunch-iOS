import SwiftUI

struct SplashBrandMarkView: View {

    @Environment(\.style) private var style

    private var logoSize: CGFloat {
        self.style.spacing(.extraLarge2)
    }

    var body: some View {

        ImageSource.image(ImageResource(name: BusinessConfig.logoAssetName, bundle: .main))
            .view()
            .aspectRatio(contentMode: .fit)
            .frame(width: self.logoSize, height: self.logoSize)
            .padding(self.style.spacing(.large))
            .background(self.style.background(.secondary))
            .clipShape(RoundedRectangle(cornerRadius: self.style.radius(.extraLarge)))
            .overlay {

                RoundedRectangle(cornerRadius: self.style.radius(.extraLarge))
                    .strokeBorder(self.style.background(.border), lineWidth: 1)

            }
            .background {

                RoundedRectangle(cornerRadius: self.style.radius(.extraLarge))
                    .fill(self.style.background(.tertiary))
                    .rotationEffect(.degrees(-8))
                    .padding(-self.style.spacing(.small))

            }
            .appShadow(.card)

    }

}

#Preview {

    SplashBrandMarkView()
        .padding(.large)
        .withMockPreviews()

}
