import SwiftUI

struct SplashBrandMarkView: View {

    @Environment(\.style) private var style

    private var logoSize: CGFloat {
        self.style.spacing(.extraLarge2) * 2
    }

    var body: some View {

        ImageSource.image(ImageResource(name: BusinessConfig.logoAssetName, bundle: .main))
            .view()
            .aspectRatio(contentMode: .fit)
            .frame(width: self.logoSize, height: self.logoSize)
            .background(self.style.background(.tertiary))
            .clipShape(RoundedRectangle(cornerRadius: self.style.radius(.extraLarge), style: .continuous))
            .overlay {

                RoundedRectangle(cornerRadius: self.style.radius(.extraLarge), style: .continuous)
                    .strokeBorder(self.style.background(.border).opacity(0.5), lineWidth: 1)

            }
            .appShadow(.offset)
            .accessibilityHidden(true)

    }

}

#Preview {

    SplashBrandMarkView()
        .padding(.large)
        .withMockPreviews()

}
