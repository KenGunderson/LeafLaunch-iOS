import SwiftUI

struct StoreInfoActionRow: View {

    @Environment(\.style) private var style

    let title: String
    let value: String
    let systemImage: String
    var showsChevron: Bool = true

    var body: some View {

        HStack(spacing: self.style.spacing(.medium)) {

            icon()
            label()

            Spacer(minLength: 0)

            if self.showsChevron {

                ImageSource.systemImage("chevron.right")
                    .view(shouldResize: false)
                    .appFont(with: .TITLE_3)
                    .foregroundStyle(self.style.textColor(.body))

            }

        }
        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
        .contentShape(Rectangle())

    }

    @ViewBuilder
    private func icon() -> some View {

        ImageSource.systemImage(self.systemImage)
            .view(shouldResize: false)
            .appFont(with: .TITLE_5)
            .foregroundStyle(self.style.palette(.link))
            .frame(width: self.style.spacing(.medium2) * 2, height: self.style.spacing(.medium2) * 2)
            .background(self.style.palette(.link).resolvedColor(style: self.style).opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: self.style.radius(.medium)))

    }

    @ViewBuilder
    private func label() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.extraSmall)) {

            Text(self.title)
                .appFont(with: .TITLE_3)
                .foregroundStyle(self.style.textColor(.title))

            Text(self.value)
                .appFont(with: .BODY_1)
                .foregroundStyle(self.style.textColor(.body))

        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .leading)
        .multilineTextAlignment(.leading)

    }

}
