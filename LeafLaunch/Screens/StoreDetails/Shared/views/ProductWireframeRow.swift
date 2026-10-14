import SwiftUI

struct ProductWireframeRow: View {

    @Environment(\.style) private var style

    let product: Product
    let isFavorite: Bool
    let onOpen: () -> Void
    let onFavorite: () -> Void

    var body: some View {

        GroupBox {

            VStack(alignment: .leading, spacing: self.style.spacing(.small)) {

                Text(self.product.displayName).appFont(with: .TITLE_4)
                Text(self.product.category?.name ?? "").appFont(with: .BODY_2)

                if let price = self.product.minimumPrice {
                    Text(price.formatted(.currency(code: self.product.currencyCode)))
                } else {
                    Text(String(localized: "Price unavailable"))
                }

                HStack {

                    Button(String(localized: "View Product"), action: self.onOpen)
                    Spacer()
                    Button(
                        self.isFavorite ? String(localized: "Remove Favorite") : String(localized: "Favorite"),
                        action: self.onFavorite
                    )

                }

            }
            .frame(maxWidth: .infinity, alignment: .leading)

        }

    }

}
