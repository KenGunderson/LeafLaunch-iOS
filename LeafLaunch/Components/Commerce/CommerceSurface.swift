import SwiftUI

struct CommerceSurface<Content: View>: View {

    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {

        LLAppCardView(cornerRadius: .large) {
            self.content
        }

    }

}

#Preview {

    CommerceSurface {

        VStack(alignment: .leading) {

            Text(MockCustomerModels.store.name)
                .appFont(with: .TITLE_4)
                .foregroundStyle(.text(.title))

            Text(MockCustomerModels.locationDetails.location.name)
                .appFont(with: .BODY_2)
                .foregroundStyle(.text(.body))

        }

    }
    .padding(.medium)
    .withMockPreviews()

}
