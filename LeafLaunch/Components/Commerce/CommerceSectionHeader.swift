import SwiftUI

struct CommerceSectionHeader: View {

    @Environment(\.style) private var style

    let title: String
    var subtitle: String?
    var systemImage: String?
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.extraSmall)) {

            HStack(spacing: self.style.spacing(.small)) {

                if let systemImage = self.systemImage {

                    ImageSource.systemImage(systemImage)
                        .view()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: self.style.spacing(.medium2), height: self.style.spacing(.medium2))
                        .foregroundStyle(self.style.foreground(.secondary))

                }

                SectionView(leadingTitle: self.title) {
                    sectionAction()
                }

            }

            if let subtitle = self.subtitle, !subtitle.isEmpty {

                Text(subtitle)
                    .appFont(with: .BODY_1)
                    .foregroundStyle(self.style.textColor(.body))
                    .fixedSize(horizontal: false, vertical: true)

            }

        }
        .frame(maxWidth: .infinity, alignment: .leading)

    }

    @ViewBuilder
    private func sectionAction() -> some View {

        if let actionTitle = self.actionTitle, let action = self.action {

            Text(actionTitle)
                .appFont(with: .TITLE_2)
                .foregroundStyle(self.style.palette(.link))
                .fixedSize(horizontal: true, vertical: true)
                .frame(minHeight: 44)
                .contentShape(Rectangle())
                .asButton(action: action)

        }

    }

}

#Preview {

    CommerceSectionHeader(
        title: "Your collection",
        subtitle: "Available at this location",
        systemImage: "heart"
    )
    .padding(.medium)
    .withMockPreviews()

}
