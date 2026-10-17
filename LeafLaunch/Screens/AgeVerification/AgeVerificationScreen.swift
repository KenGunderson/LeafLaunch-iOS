import SwiftUI

struct AgeVerificationScreen: GPView {

    @Environment(\.style) private var style

    @StateObject private var viewModel: AgeVerificationViewModel

    init(viewModel: AgeVerificationViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {

        LLAppHeaderScrollView {
            navHeader()
        } scrollViewContent: {
            content()
        }
        .interactiveDismissDisabled()
        .onFirstAppear { [weak viewModel] in viewModel?.handleFirstAppear() }

    }

    @ViewBuilder
    private func navHeader() -> some View {

        StoreNavHeader(
            configuration: self.viewModel.configuration,
            subtitle: String(localized: "Age verification")
        )
        .safeAreaPadding(.top, self.style.spacing(.medium))

    }

    @ViewBuilder
    private func content() -> some View {

        AgeVerificationConsentView(
            minimumAge: self.viewModel.minimumAge,
            locationDetails: self.viewModel.locationDetails,
            isApproving: self.viewModel.isApproving,
            approveAction: { [weak viewModel] in viewModel?.approve() }
        )
        .padding(.top, .small)
        .padding(.bottom, .large)

    }

}

#Preview {

    AgeVerificationScreen(
        viewModel: mockResolve(AgeVerificationViewModel.self)
            .setup(locationId: MockCustomerModels.primaryLocationId)
    )
    .withMockPreviews()

}
