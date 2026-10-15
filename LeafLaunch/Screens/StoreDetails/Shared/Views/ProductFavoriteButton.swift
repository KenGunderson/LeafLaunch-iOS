import SwiftUI

struct ProductFavoriteButton: View {

    @Environment(\.style) private var style

    let isFavorite: Bool
    let action: () -> Void

    var body: some View {

        Image(systemName: self.isFavorite ? "heart.fill" : "heart")
            .resizable()
            .frame(width: 22, height: 22)
            .foregroundStyle(self.isFavorite ? self.style.foreground(.primary) : self.style.textColor(.title))
            .frame(width: 44, height: 44)
            .background(.background(.secondary))
            .clipShape(RoundedRectangle(cornerRadius: self.style.radius(.extraLarge)))
            .overlay {

                RoundedRectangle(cornerRadius: self.style.radius(.extraLarge))
                    .strokeBorder(self.style.background(.border), lineWidth: 1)

            }
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
