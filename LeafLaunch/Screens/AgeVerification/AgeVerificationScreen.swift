import SwiftUI

struct AgeVerificationScreen: GPView {

    @Environment(\.style) private var style

    @StateObject private var viewModel: AgeVerificationViewModel

    init(viewModel: AgeVerificationViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {

        AppHeaderScrollView(horizontalPadding: .medium) {
            NavHeader(title: String(localized: "Age Verification"))
        } scrollViewContent: {

            GroupBox {

                VStack(alignment: .leading, spacing: self.style.spacing(.medium)) {

                    Text(String(localized: "You must be at least \(self.viewModel.minimumAge) years old to continue."))
                        .appFont(with: .BODY_2)

                    Text(self.viewModel.stateName).appFont(with: .BODY_2)

                    LeafLaunchButton(title: String(localized: "I am \(self.viewModel.minimumAge) or older")) {
                        self.viewModel.approve()
                    }

                }
                .frame(maxWidth: .infinity, alignment: .leading)

            }

        }
        .interactiveDismissDisabled()
        .onFirstAppear { [weak viewModel] in viewModel?.handleFirstAppear() }

    }

}

#Preview {

    AgeVerificationScreen(
        viewModel: mockResolve(AgeVerificationViewModel.self)
            .setup(locationId: MockCustomerModels.primaryLocationId)
    )
    .withMockServices()

}
