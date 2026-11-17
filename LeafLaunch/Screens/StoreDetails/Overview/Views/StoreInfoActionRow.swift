import SwiftUI

struct StoreInfoActionRow: View {

    @Environment(\.style) private var style

    let title: String
    let value: String
    let systemImage: String
    var showsChevron: Bool = true

    var body: some View {

        HStack(spacing: self.style.spacing(LLSpacing.cardContent)) {

            icon()
            label()

            if self.showsChevron {

                RNImageSource.systemImage("chevron.right")
                    .view(shouldResize: false)
                    .runeFont(with: .NOTE_2)
                    .runeTextColor(.body)

            }

        }
        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
        .contentShape(Rectangle())

    }

    @ContentBuilder
    private func icon() -> some View {

        RNImageSource.systemImage(self.systemImage)
            .view(shouldResize: false)
            .runeFont(with: .TITLE_4)
            .foregroundStyle(RNColorSource.palette(.link))
            .frame(
                width: 36,
                height: 36
            )
            .background(RNColorSource.palette(.link).opacity(0.08))
            .runeCornerRadius(.medium)
            .runeBorder(
                cornerRadius: .medium,
                color: RNColorSource.palette(.link),
                lineWidth: 0.8
            )

    }

    @ContentBuilder
    private func label() -> some View {

        VStack(
            alignment: .leading,
            spacing: self.style.spacing(LLSpacing.none)
        ) {

            Text(self.title)
                .runeFont(with: .TITLE_2)
                .runeTextColor(.title)

            Text(self.value)
                .runeFont(with: .BODY_1)
                .runeTextColor(.body)

        }
        .fixedSize(
            horizontal: false,
            vertical: true
        )
        .frame(maxWidth: .infinity, alignment: .leading)
        .multilineTextAlignment(.leading)

    }

}
