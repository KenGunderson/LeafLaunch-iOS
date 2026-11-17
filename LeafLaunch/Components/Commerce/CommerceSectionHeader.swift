import SwiftUI

struct CommerceSectionHeader: View {

    @Environment(\.style) private var style

    let title: String
    var subtitle: String?
    var systemImage: String?
    var actionTitle: String?
    var action: (() -> Void)?
    var titleFont: RNTheme.FontKey = LeafLaunchThemeTokens.headingFont
    var titleColor: RNColorSource = .text(.title)
    var imageSource: RNImageSource?
    var imageColor: RNColorSource = .foreground(.secondary)
    var imageSize: CGFloat = 20
    var actionFont: RNTheme.FontKey = .TITLE_2
    var actionColor: RNColorSource = .palette(.link)

    var body: some View {

        VStack(
            alignment: .leading,
            spacing: self.style.spacing(LLSpacing.metadata)
        ) {

            HStack(spacing: self.style.spacing(LLSpacing.groupedContent)) {

                if let imageSource = self.imageSource ?? self.systemImage.map(RNImageSource.systemImage) {

                    imageSource
                        .view()
                        .aspectRatio(contentMode: .fill)
                        .frame(
                            width: self.imageSize,
                            height: self.imageSize
                        )
                        .foregroundStyle(self.imageColor)

                }

                SectionView(
                    leadingTitle: self.title,
                    leadingForegroundColor: self.titleColor,
                    titleFont: self.titleFont
                ) {
                    sectionAction()
                }

            }

            if let subtitle = self.subtitle, !subtitle.isEmpty {

                Text(subtitle)
                    .runeFont(with: .BODY_1)
                    .runeTextColor(.body)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )

            }

        }
        .frame(maxWidth: .infinity, alignment: .leading)

    }

    @ContentBuilder
    private func sectionAction() -> some View {

        if let actionTitle = self.actionTitle, let action = self.action {

            Text(actionTitle)
                .runeFont(with: self.actionFont)
                .foregroundStyle(self.actionColor)
                .fixedSize(
                    horizontal: true,
                    vertical: true
                )
                .contentShape(Rectangle().inset(by: -self.style.spacing(LLSpacing.section)))
                .runeAsButton(action: action)

        }

    }

}

#Preview {

    CommerceSectionHeader(
        title: "Your Collection",
        subtitle: "Available At This Location",
        systemImage: "heart"
    )
    .runePadding(LLSpacing.pageInset)
    .withMockPreviews()

}
