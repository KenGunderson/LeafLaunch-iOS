import SwiftUI

struct CatalogFilterPill: View {

    @Environment(\.style) private var style
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {

        HStack(spacing: self.style.spacing(.extraSmall)) {

            if self.isSelected {

                ImageSource.systemImage("checkmark")
                    .view()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: self.style.spacing(.small2), height: self.style.spacing(.small2))
                    .accessibilityHidden(true)
                    .transition(.opacity)

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
        .asButton(scale: self.reduceMotion ? 1 : nil, action: self.action)
        .accessibilityAddTraits(self.isSelected ? .isSelected : [])
        .animation(self.reduceMotion ? nil : .bouncy, value: self.isSelected)

    }

}

#Preview {

    @Previewable @State var isSelected = true

    CatalogFilterPill(title: "All products", isSelected: isSelected) {
        isSelected.toggle()
    }
    .padding(.medium)
    .withMockPreviews()

}
