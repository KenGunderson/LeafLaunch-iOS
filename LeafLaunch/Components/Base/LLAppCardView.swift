import SwiftUI

struct LLAppCardView<Content: View>: View {

    private let verticalPadding: Theme.SpacingKey
    private let horizontalPadding: Theme.SpacingKey
    private let backgroundStyle: ColorSource
    private let cornerRadius: Theme.RadiusKey
    private let borderColor: ColorSource?
    private let content: Content

    init(verticalPadding: Theme.SpacingKey = .medium,
         horizontalPadding: Theme.SpacingKey = .medium,
         backgroundStyle: ColorSource = .background(.secondary),
         cornerRadius: Theme.RadiusKey = .small2,
         borderColor: ColorSource? = nil,
         @ViewBuilder content: () -> Content) {

        self.verticalPadding = verticalPadding
        self.horizontalPadding = horizontalPadding
        self.backgroundStyle = backgroundStyle
        self.cornerRadius = cornerRadius
        self.borderColor = borderColor
        self.content = content()

    }

    var body: some View {

        AppCardView(
            verticalPadding: self.verticalPadding,
            horizontalPadding: self.horizontalPadding,
            backgroundStyle: self.backgroundStyle,
            cornerRadius: self.cornerRadius,
            shadow: .none
        ) {
            self.content
        }
        .appBorder(
            cornerRadius: self.cornerRadius,
            color: self.borderColor ?? .background(.border),
            lineWidth: 0.8
        )

    }

}

#Preview {

    LLAppCardView {

        Text(MockCustomerModels.store.name)
            .appFont(with: .TITLE_4)
            .foregroundStyle(.text(.title))

    }
    .padding(.medium)
    .withMockPreviews()

}
