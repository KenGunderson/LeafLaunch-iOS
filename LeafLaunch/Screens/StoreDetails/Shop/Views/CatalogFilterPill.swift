import SwiftUI

struct CatalogFilterPill: View {

    @Environment(\.style) private var style

    let title: String
    var imageURL: URL? = nil
    let isSelected: Bool
    let action: () -> Void

    var body: some View {

        HStack(spacing: self.style.spacing(.small)) {

            if let imageURL = self.imageURL {
                categoryImage(url: imageURL)
            }

            Text(self.title)
                .appFont(with: .TITLE_2)
                .fixedSize(horizontal: true, vertical: false)

        }
        .foregroundStyle(self.isSelected ? self.style.textColor(.button) : self.style.textColor(.title))
        .padding(.horizontal, .medium)
        .padding(.vertical, .small2)
        .frame(minHeight: 44)
        .background(self.isSelected ? self.style.foreground(.primary) : self.style.background(.secondary))
        .clipShape(Capsule())
        .overlay {

            Capsule()
                .strokeBorder(
                    self.isSelected ? self.style.foreground(.primary) : self.style.background(.border),
                    lineWidth: 1
                )
                .allowsHitTesting(false)

        }
        .contentShape(Capsule())
        .asButton(action: self.action)
        .animation(.bouncy, value: self.isSelected)

    }

    @ViewBuilder
    private func categoryImage(url: URL) -> some View {

        ProductCategoryImageView(url: url)
            .frame(width: self.style.spacing(.medium2), height: self.style.spacing(.medium2))

    }

}

#Preview {

    @Previewable @State var isSelected = true

    CatalogFilterPill(title: "Flower", imageURL: MockCustomerModels.categories.first?.imageURL, isSelected: isSelected) {
        isSelected.toggle()
    }
    .padding(.medium)
    .withMockPreviews()

}
