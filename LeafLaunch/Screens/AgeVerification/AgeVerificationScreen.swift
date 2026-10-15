import SwiftUI

struct AgeVerificationScreen: GPView {

    @Environment(\.style) private var style

    @StateObject private var viewModel: AgeVerificationViewModel

    init(viewModel: AgeVerificationViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {

        AppHeaderScrollView(horizontalPadding: .medium) {
            navHeader()
        } scrollViewContent: {
            content()
        }
        .interactiveDismissDisabled()
        .onFirstAppear { [weak viewModel] in viewModel?.handleFirstAppear() }

    }

    private func navHeader() -> some View {
        NavHeader(title: String(localized: "Age Verification"))
    }

    private func content() -> some View {

        AgeVerificationConsentView(
            minimumAge: self.viewModel.minimumAge,
            stateName: self.viewModel.stateName,
            isApproving: self.viewModel.isApproving,
            approveAction: { [weak viewModel] in viewModel?.approve() }
        )
        .padding(.vertical, self.style.spacing(.large))

    }

}

#Preview {

    AgeVerificationScreen(
        viewModel: mockResolve(AgeVerificationViewModel.self)
            .setup(locationId: MockCustomerModels.primaryLocationId)
    )
    .withMockPreviews()

}
