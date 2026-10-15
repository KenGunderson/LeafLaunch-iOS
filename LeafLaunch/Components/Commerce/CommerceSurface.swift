import SwiftUI

struct CommerceSurface<Content: View>: View {

    @Environment(\.style) private var style

    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {

        AppCardView(cornerRadius: .large, shadow: .card) {
            self.content
        }
        .overlay {

            RoundedRectangle(cornerRadius: self.style.radius(.large))
                .strokeBorder(self.style.background(.border), lineWidth: 1)
                .allowsHitTesting(false)

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
