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

    private var selection: Binding<String?> {

        Binding(
            get: { self.currentPromotionId },
            set: { self.selectedPromotionId = $0 }
        )

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
            return
        }

        guard !Task.isCancelled else { return }
        let index = (self.currentIndex + 1) % self.promotions.count

        if index == 0 {

            var transaction = Transaction(animation: nil)
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                self.selectedPromotionId = self.promotions[index].id
            }

        } else {

            self.selectedPromotionId = self.promotions[index].id

        }

    }

    var body: some View {

        VStack(spacing: 6) {

            pages()

            if self.promotions.count > 1 {
                pageIndicators()
            }

        }
        .task(id: self.autoScrollKey) {
            await advancePromotion()
        }
        .onChange(of: self.promotions.map(\.id)) { _, _ in
            self.selectedPromotionId = self.currentPromotionId
        }

    }

    @ViewBuilder
    private func pages() -> some View {

        ScrollView(.horizontal) {

            HStack(alignment: .top, spacing: self.style.spacing(.medium)) {

                ForEach(self.promotions) { promotion in
                    promotionCard(promotion)
                }

            }
            .fixedSize(horizontal: false, vertical: true)
            .scrollTargetLayout()

        }
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition(id: self.selection, anchor: .center)
        .scrollIndicators(.hidden)
        .safeAreaPadding(.horizontal, self.style.spacing(.medium))
        .onScrollPhaseChange { _, phase in
            self.isScrolling = phase != .idle
        }
        .animation(.easeInOut(duration: 0.65), value: self.selectedPromotionId)

    }

    @ViewBuilder
    private func promotionCard(_ promotion: Promotion) -> some View {

        StorePromotionCard(promotion: promotion)
            .if(promotion.kind != .general) { view in
                view.asButton { self.onOpen(promotion) }
            }
            .containerRelativeFrame(.horizontal)
            .id(promotion.id)

    }

    @ViewBuilder
    private func pageIndicators() -> some View {

        if self.promotions.count <= 8 {

            HStack(spacing: self.style.spacing(.small)) {

                ForEach(self.promotions) { promotion in

                    Circle()
                        .fill(promotion.id == self.currentPromotionId ? self.style.foreground(.primary) : self.style.background(.border))
                        .frame(width: 6, height: 6)

                }

            }

        } else {

            Text(String(localized: "\(self.currentIndex + 1) of \(self.promotions.count)"))
                .appFont(with: .NOTE_1)
                .foregroundStyle(.text(.body))
                .monospacedDigit()

        }

    }

}

#Preview {

    ScrollView {

        StorePromotionsCarousel(promotions: MockCustomerModels.promotions) { _ in }

    }
    .withMockPreviews()

}
