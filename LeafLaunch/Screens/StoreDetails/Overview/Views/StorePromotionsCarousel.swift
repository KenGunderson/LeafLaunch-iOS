import SwiftUI

struct StorePromotionsCarousel: View {

    @Environment(\.style) private var style
    @Environment(\.scenePhase) private var scenePhase

    @State private var selectedPromotionId: String?
    @State private var isScrolling = false

    let promotions: [Promotion]
    let onOpen: (Promotion) -> Void

    private var currentPromotionId: String? {

        if self.promotions.contains(where: { $0.id == self.selectedPromotionId }) {
            return self.selectedPromotionId
        }

        return self.promotions.first?.id

    }

    private var currentIndex: Int {
        self.promotions.firstIndex { $0.id == self.currentPromotionId } ?? 0
    }

    private var autoScrollKey: [String] {

        guard self.scenePhase == .active,
              !self.isScrolling,
              self.promotions.count > 1,
              let currentPromotionId = self.currentPromotionId else { return [] }
        return [currentPromotionId] + self.promotions.map(\.id)

    }

    @MainActor
    private func advancePromotion() async {

        guard !self.autoScrollKey.isEmpty else { return }

        do {
            try await Task.sleep(for: .seconds(5))
        } catch {

            guard !Task.isCancelled else { return }
            return

        }

        guard !Task.isCancelled else { return }
        let index = (self.currentIndex + 1) % self.promotions.count

        scrollToPromotion(
            at: index,
            animated: true
        )

    }

    private func scrollToPromotion(at index: Int, animated: Bool) {

        guard self.promotions.indices.contains(index) else { return }

        withAnimation(animated ? .bouncy(duration: 0.65) : nil) {
            self.selectedPromotionId = self.promotions[index].id
        }

    }

    var body: some View {

        VStack(spacing: self.style.spacing(LLSpacing.compact)) {

            pages()

            if self.promotions.count > 1 {
                pageIndicators()
            }

        }
        .task(id: self.autoScrollKey) {
            await advancePromotion()
        }
        .onChange(of: self.promotions.map(\.id)) { _, _ in

            scrollToPromotion(
                at: self.currentIndex,
                animated: false
            )

        }

    }

    @ContentBuilder
    private func pages() -> some View {

        ScrollView(.horizontal) {

            HStack(
                alignment: .top,
                spacing: self.style.spacing(LLSpacing.groupedContent)
            ) {

                ForEach(self.promotions) { promotion in
                    promotionCard(promotion)
                }

            }
            .fixedSize(
                horizontal: false,
                vertical: true
            )
            .scrollTargetLayout()

        }
        .safeAreaPadding(.horizontal, self.style.spacing(.medium))
        .scrollPosition(
            id: self.$selectedPromotionId,
            anchor: .leading
        )
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.viewAligned)
        .onScrollPhaseChange { _, phase in
            self.isScrolling = phase != .idle
        }

    }

    @ContentBuilder
    private func promotionCard(_ promotion: Promotion) -> some View {

        StorePromotionCard(promotion: promotion) {
            self.onOpen(promotion)
        }
        .containerRelativeFrame(.horizontal) { width, _ in
            return width
        }
        .id(promotion.id)

    }

    @ContentBuilder
    private func pageIndicators() -> some View {

        if self.promotions.count <= 8 {

            HStack(spacing: self.style.spacing(LLSpacing.groupedContent)) {

                ForEach(self.promotions) { promotion in

                    Circle()
                        .runeFill(promotion.id == self.currentPromotionId ? RNColorSource.palette(.link) : RNColorSource.background(.border))
                        .frame(
                            width: self.style.spacing(LLSpacing.groupedContent),
                            height: self.style.spacing(LLSpacing.groupedContent)
                        )

                }

            }

        } else {

            Text(String(localized: "\(self.currentIndex + 1) of \(self.promotions.count)"))
                .monospacedDigit()
                .runeFont(with: .NOTE_1)
                .runeTextColor(.body)

        }

    }

}

#Preview {

    ScrollView {
        StorePromotionsCarousel(promotions: MockCustomerModels.promotions) { _ in }
    }
    .withMockPreviews()

}
