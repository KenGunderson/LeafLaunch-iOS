import SwiftUI

struct LLAppCardView<Content: View>: View {

    private let verticalPadding: RNTheme.SpacingKey
    private let horizontalPadding: RNTheme.SpacingKey
    private let backgroundStyle: RNColorSource
    private let cornerRadius: RNTheme.RadiusKey
    private let borderColor: RNColorSource?
    private let content: Content

    init(verticalPadding: RNTheme.SpacingKey = LLSpacing.pageInset,
         horizontalPadding: RNTheme.SpacingKey = LLSpacing.pageInset,
         backgroundStyle: RNColorSource = .background(.secondary),
         cornerRadius: RNTheme.RadiusKey = .small2,
         borderColor: RNColorSource? = nil,
         @ContentBuilder content: () -> Content) {

        self.verticalPadding = verticalPadding
        self.horizontalPadding = horizontalPadding
        self.backgroundStyle = backgroundStyle
        self.cornerRadius = cornerRadius
        self.borderColor = borderColor
        self.content = content()

    }

    var body: some View {

        RNCardView(
            verticalPadding: self.verticalPadding,
            horizontalPadding: self.horizontalPadding,
            backgroundStyle: self.backgroundStyle,
            cornerRadius: self.cornerRadius,
            shadow: .none
        ) {
            self.content
        }
        .runeBorder(
            cornerRadius: self.cornerRadius,
            color: self.borderColor ?? .background(.border),
            lineWidth: 0.8
        )

    }

}

#Preview {

    LLAppCardView {

        Text(MockCustomerModels.store.name)
            .runeFont(with: .TITLE_4)
            .runeTextColor(.title)

    }
    .runePadding(LLSpacing.pageInset)
    .withMockPreviews()

}
