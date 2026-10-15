import SwiftUI

struct LLAppCardView<Content: View>: View {

    private let verticalPadding: Theme.SpacingKey
    private let horizontalPadding: Theme.SpacingKey
    private let backgroundStyle: ColorSource
    private let cornerRadius: Theme.RadiusKey
    private let content: Content

    init(verticalPadding: Theme.SpacingKey = .medium,
         horizontalPadding: Theme.SpacingKey = .medium,
         backgroundStyle: ColorSource = .background(.secondary),
         cornerRadius: Theme.RadiusKey = .small2,
         @ViewBuilder content: () -> Content) {

        self.verticalPadding = verticalPadding
        self.horizontalPadding = horizontalPadding
        self.backgroundStyle = backgroundStyle
        self.cornerRadius = cornerRadius
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
        .appBorder(cornerRadius: self.cornerRadius, lineWidth: 1.5)

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
