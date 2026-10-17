import SwiftUI

struct StorePromotionCard: View {

    let promotion: Promotion

    private var subtitle: String? {

        guard let description = self.promotion.description?.trimmingCharacters(in: .whitespacesAndNewlines),
              !description.isEmpty else { return nil }
        return description

    }

    var body: some View {

        LLAppCardView(
            verticalPadding: .none,
            horizontalPadding: .none,
            backgroundStyle: .color(.clear),
            cornerRadius: .large
        ) {

            StoreMarketingImage(
                url: self.promotion.image?.url,
                placeholder: ImageResource(name: "StorePromotionFallback", bundle: .main)
            )
            .aspectRatio(1.9, contentMode: .fit)
            .overlay(alignment: .bottom) {
                caption()
            }

        }

    }

    @ViewBuilder
    private func caption() -> some View {

        VStack(alignment: .leading, spacing: 2) {

            Text(self.promotion.title)
                .appFont(with: .TITLE_3)
                .lineLimit(1)
                .minimumScaleFactor(0.5)

            if let subtitle = self.subtitle {

                Text(subtitle)
                    .appFont(with: .BODY_1)
                    .lineLimit(2)

            }

        }
        .foregroundStyle(Color.white)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, .small)
        .padding(.bottom, .small)
        .padding(.top, .large)
        .background {

            LinearGradient(
                stops: [
                    .init(color: .black.opacity(0), location: 0),
                    .init(color: .black.opacity(0.55), location: 0.35),
                    .init(color: .black.opacity(0.85), location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

        }

    }

}

#Preview {

    if let promotion = MockCustomerModels.promotions.first {

        StorePromotionCard(promotion: promotion)
            .padding(.medium)
            .withMockPreviews()

    }

}
