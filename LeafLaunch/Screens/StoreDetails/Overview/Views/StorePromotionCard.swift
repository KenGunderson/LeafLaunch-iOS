import SwiftUI

struct StorePromotionCard: View {

    @Environment(\.style) private var style

    let promotion: Promotion
    let onOpen: () -> Void

    private var categoryTitle: String {

        switch self.promotion.kind {
        case .general: return String(localized: "Store Update")
        case .sale: return String(localized: "Special Offer")
        case .newProduct: return String(localized: "New Arrival")
        case .link: return String(localized: "Discover More")
        }

    }

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

            VStack(alignment: .leading, spacing: self.style.spacing(.small2)) {

                promotionCopy()
                
                Spacer()
                
                offerAction()

            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(.medium)
            .background {

                self.style.palette(.link).view()
                    .overlay(Color.black.opacity(0.78))

            }
            .asButton {
                self.onOpen()
            }

        }

    }

    @ViewBuilder
    private func promotionCopy() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.extraSmall)) {

            Text(self.categoryTitle)
                .appFont(with: .TITLE_1)
                .textCase(.uppercase)
                .foregroundStyle(Color.white.opacity(0.76))

            Text(self.promotion.title)
                .appFont(with: .HEADER_4)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .foregroundStyle(Color.white)

            if let subtitle = self.subtitle {

                Text(subtitle)
                    .appFont(with: .BODY_1)
                    .lineLimit(2)
                    .foregroundStyle(Color.white.opacity(0.76))

            }

        }
        .frame(maxWidth: .infinity, alignment: .leading)

    }

    @ViewBuilder
    private func offerAction() -> some View {

        if self.promotion.kind != .general {

            CommonButton(
                title: String(localized: "View offer"),
                titleColor: .text(.titleInverted),
                titleFont: .TITLE_3,
                icon: .systemImage("chevron.right"),
                iconAlignment: .trailing,
                backgroundStyle: .palette(.link),
                verticalPadding: .small2,
                horizontalPadding: .medium,
                cornerRadius: .medium2,
                action: self.onOpen
            )
            .fixedSize(horizontal: true, vertical: false)

        }

    }

}

#Preview {

    if let promotion = MockCustomerModels.promotions.first {

        StorePromotionCard(promotion: promotion, onOpen: {})
            .padding(.medium)
            .withMockPreviews()

    }

}
