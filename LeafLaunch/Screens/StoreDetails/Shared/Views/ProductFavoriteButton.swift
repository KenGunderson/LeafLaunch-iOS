import SwiftUI

struct ProductFavoriteButton: View {

    @Environment(\.style) private var style
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let isFavorite: Bool
    let productName: String
    let action: () -> Void

    var body: some View {

        Button(action: self.action) {

            ImageSource.systemImage(self.isFavorite ? "heart.fill" : "heart")
                .view(shouldResize: false)
                .appFont(with: .TITLE_4)
                .foregroundStyle(self.isFavorite ? self.style.foreground(.primary) : self.style.textColor(.title))
                .frame(width: 44, height: 44)
                .background(.background(.secondary))
                .clipShape(RoundedRectangle(cornerRadius: self.style.radius(.extraLarge)))
                .overlay {

                    RoundedRectangle(cornerRadius: self.style.radius(.extraLarge))
                        .strokeBorder(self.style.background(.border), lineWidth: 1)

                }
                .scaleEffect(self.isFavorite && !self.reduceMotion ? 1.06 : 1)

        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            self.isFavorite
                ? String(localized: "Remove \(self.productName) from favorites")
                : String(localized: "Save \(self.productName) to favorites")
        )
        .accessibilityValue(self.isFavorite ? String(localized: "Saved") : String(localized: "Not saved"))
        .animation(self.reduceMotion ? nil : .bouncy, value: self.isFavorite)

    }

}

#Preview {

    @Previewable @State var isFavorite = false

    if let product = MockCustomerModels.products.first {

        ProductFavoriteButton(
            isFavorite: isFavorite,
            productName: product.displayName,
            action: { isFavorite.toggle() }
        )
        .padding(.medium)
        .withMockPreviews()

    }

}
