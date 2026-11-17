import SwiftUI

struct CommerceSurface<Content: View>: View {

    private let content: Content

    init(@ContentBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {

        LLAppCardView(cornerRadius: .large) {
            self.content
        }

    }

}

#Preview {

    @Previewable @Environment(\.style) var style

    CommerceSurface {

        VStack(
            alignment: .leading,
            spacing: style.spacing(LLSpacing.listRow)
        ) {

            Text(MockCustomerModels.store.name)
                .runeFont(with: .TITLE_4)
                .runeTextColor(.title)

            Text(MockCustomerModels.locationDetails.location.name)
                .runeFont(with: .BODY_2)
                .runeTextColor(.body)

        }

    }
    .runePadding(LLSpacing.pageInset)
    .withMockPreviews()

}
