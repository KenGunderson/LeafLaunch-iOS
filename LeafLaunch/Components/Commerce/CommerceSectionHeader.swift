import SwiftUI

struct CommerceSectionHeader: View {

    @Environment(\.style) private var style

    let title: String
    var subtitle: String?
    var systemImage: String?

    var body: some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.extraSmall)) {

            HStack(spacing: self.style.spacing(.small)) {

                if let systemImage = self.systemImage {

                    ImageSource.systemImage(systemImage)
                        .view()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: self.style.spacing(.medium2), height: self.style.spacing(.medium2))
                        .foregroundStyle(self.style.foreground(.secondary))
                        .accessibilityHidden(true)

                }

                SectionView(leadingTitle: self.title)
                    .accessibilityAddTraits(.isHeader)

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
