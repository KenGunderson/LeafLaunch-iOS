import SwiftUI

struct ProductFavoriteButton: View {

    @Environment(\.style) private var style

    let isFavorite: Bool
    let action: () -> Void

    var body: some View {

        ImageSource.systemImage(self.isFavorite ? "heart.fill" : "heart")
            .view()
            .frame(width: 18, height: 18)
            .foregroundStyle(self.isFavorite ? self.style.palette(.link) : self.style.textColor(.title))
            .frame(width: 32, height: 32)
            .background(.background(.secondary))
            .clipShape(Circle())
            .overlay {

                Circle()
                    .strokeBorder(self.style.background(.border), lineWidth: 1)

            }
            .frame(width: 44, height: 44)
            .contentShape(Rectangle())
            .asButton {
                self.action()
            }
            .symbolEffect(.bounce, value: self.isFavorite)
            .animation(.bouncy, value: self.isFavorite)

    }

}

#Preview {

    @Previewable @State var isFavorite = false

    ProductFavoriteButton(
        isFavorite: isFavorite,
        action: { isFavorite.toggle() }
    )
    .padding(.medium)
    .withMockPreviews()

}
