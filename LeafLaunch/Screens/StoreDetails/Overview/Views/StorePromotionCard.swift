import SwiftUI

struct StorePromotionCard: View {

    @Environment(\.style) private var style

    let promotion: Promotion
    let location: StoreLocation?
    let onSelectProduct: (PromotionLinkedProduct) -> Void

    private var schedule: PromotionLocation? {
        self.promotion.locations?.first { $0.storeLocationId == self.location?.id }
    }

    private var timeZone: TimeZone {
        (self.schedule?.timezone ?? self.location?.timezone).flatMap(TimeZone.init(identifier:)) ?? .autoupdatingCurrent
    }

    private var linkedProducts: [PromotionLinkedProduct] {
        (self.promotion.linkedProducts ?? []).filter { $0.storeLocationId == self.location?.id }
    }

    private func formattedDate(_ date: Date) -> String {
        date.formatted(Date.FormatStyle(date: .abbreviated, time: .shortened, timeZone: self.timeZone))
    }

    var body: some View {

        AppCardView(
            verticalPadding: .none,
            horizontalPadding: .none,
            cornerRadius: .large,
            shadow: .card
        ) {

            VStack(alignment: .leading, spacing: 0) {

                if let imageURL = self.promotion.image?.url {

                    ImageSource.remote(
                        url: imageURL,
                        contentMode: .fill,
                        placeholder: AnyView(Rectangle().fill(.background(.tertiary)))
                    )
                    .view()
                    .aspectRatio(1.6, contentMode: .fit)
                    .clipped()
                    .accessibilityHidden(true)

                }

                VStack(alignment: .leading, spacing: self.style.spacing(.small2)) {

                    HStack(spacing: self.style.spacing(.small)) {

                        ImageSource.systemImage("tag")
                            .view(shouldResize: false)
                        Text(String(localized: "Promotion"))

                    }
                    .appFont(with: .TITLE_2)
                    .foregroundStyle(.foreground(.primary))

                    Text(self.promotion.title)
                        .appFont(with: .HEADER_3)
                        .foregroundStyle(.text(.title))
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityAddTraits(.isHeader)

                    if let description = self.promotion.description, !description.isEmpty {

                        Text(description)
                            .appFont(with: .BODY_2)
                            .foregroundStyle(.text(.body))
                            .fixedSize(horizontal: false, vertical: true)

                    }

                    scheduleView()
                    linkedProductsView()

                }
                .padding(.medium)

            }

        }

    }

    @ViewBuilder
    private func scheduleView() -> some View {

        let startsAt = self.schedule?.startsAt ?? self.promotion.startsAt
        let endsAt = self.schedule?.endsAt ?? self.promotion.endsAt

        if startsAt != nil || endsAt != nil {

            VStack(alignment: .leading, spacing: self.style.spacing(.extraSmall)) {

                if let startsAt {
                    Text(String(localized: "Starts \(formattedDate(startsAt))"))
                }

                if let endsAt {
                    Text(String(localized: "Ends \(formattedDate(endsAt))"))
                }

                Text(self.timeZone.identifier)

            }
            .appFont(with: .NOTE_1)
            .foregroundStyle(.text(.body))
            .fixedSize(horizontal: false, vertical: true)

        }

    }

    @ViewBuilder
    private func linkedProductsView() -> some View {

        if !self.linkedProducts.isEmpty {

            Divider()

            VStack(alignment: .leading, spacing: self.style.spacing(.small)) {

                Text(String(localized: "Featured products"))
                    .appFont(with: .TITLE_2)
                    .foregroundStyle(.text(.title))

                ForEach(self.linkedProducts) { product in

                    Button {
                        self.onSelectProduct(product)
                    } label: {

                        HStack(spacing: self.style.spacing(.small)) {

                            Text(product.displayName)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            ImageSource.systemImage("arrow.up.right")
                                .view(shouldResize: false)
                                .accessibilityHidden(true)

                        }
                        .appFont(with: .TITLE_3)
                        .foregroundStyle(.foreground(.primary))
                        .padding(.vertical, .small2)
                        .frame(minHeight: 44)
                        .contentShape(Rectangle())

                    }
                    .buttonStyle(.plain)

                }

            }

        }

    }

}

#Preview {

    if let promotion = MockCustomerModels.promotions.first {

        ScrollView {

            StorePromotionCard(
                promotion: promotion,
                location: MockCustomerModels.locationDetails.location,
                onSelectProduct: { _ in }
            )
            .padding(.medium)

        }
        .withMockPreviews()

    }

}
