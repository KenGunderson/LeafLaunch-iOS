import SwiftUI

// A contextual empty state keeps the surrounding catalog filters and actions available.
struct CommerceEmptyState: View {

    @Environment(\.style) private var style

    let systemImage: String
    let title: String
    let message: String

    var body: some View {

        VStack(spacing: self.style.spacing(.small2)) {

            ImageSource.systemImage(self.systemImage)
                .view()
                .aspectRatio(contentMode: .fill)
                .frame(width: self.style.spacing(.large2), height: self.style.spacing(.large2))
                .foregroundStyle(self.style.foreground(.secondary))
                .padding(.medium)
                .background(self.style.background(.tertiary), in: Circle())

            Text(self.title)
                .appFont(with: .TITLE_5)
                .foregroundStyle(self.style.textColor(.title))

            Text(self.message)
                .appFont(with: .BODY_2)
                .foregroundStyle(self.style.textColor(.body))
                .fixedSize(horizontal: false, vertical: true)

        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(.vertical, .large)
        .padding(.horizontal, .medium)

    }

}

#Preview {

    CommerceEmptyState(
        systemImage: "heart",
        title: "No Favorites Yet",
        message: "Save a product to find it here later."
    )
    .withMockPreviews()

}
