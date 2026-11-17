import SwiftUI

struct SplashBrandMarkView: View {

    @Environment(\.style) private var style

    private var logoSize: CGFloat {
        self.style.spacing(.extraLarge2) * 2
    }

    var body: some View {

        RNImageSource.image(ImageResource(
            name: BusinessConfig.logoAssetName,
            bundle: .main
        ))
            .view()
            .aspectRatio(contentMode: .fit)
            .frame(
                width: self.logoSize,
                height: self.logoSize
            )
            .runeBackground(.tertiary)
            .clipShape(RoundedRectangle(
                cornerRadius: self.style.radius(.extraLarge),
                style: .continuous
            ))
            .overlay {

                RoundedRectangle(
                    cornerRadius: self.style.radius(.extraLarge),
                    style: .continuous
                )
                    .strokeBorder(
                        RNColorSource.background(.border).opacity(0.5),
                        lineWidth: 1
                    )

            }
            .runeShadow(.offset)
            .accessibilityHidden(true)

    }

}

#Preview {

    SplashBrandMarkView()
        .runePadding(LLSpacing.content)
        .withMockPreviews()

}
