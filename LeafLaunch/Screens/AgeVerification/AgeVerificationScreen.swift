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
        .scrollBounceBehavior(.basedOnSize)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            approvalActions()
        }
        .interactiveDismissDisabled()
        .onFirstAppear { [weak viewModel] in viewModel?.handleFirstAppear() }

    }

    @ViewBuilder
    private func navHeader() -> some View {

        StoreNavHeader(
            configuration: self.viewModel.configuration,
            subtitle: nil,
            onBack: { [weak viewModel] in viewModel?.changeLocation() }
        )
        .safeAreaPadding(.top, self.style.spacing(.medium))
        .disabled(self.viewModel.isApproving)

    }

    @ViewBuilder
    private func content() -> some View {

        AgeVerificationConsentView(
            minimumAge: self.viewModel.minimumAge,
            locationDetails: self.viewModel.locationDetails,
            changeLocationAction: { [weak viewModel] in viewModel?.changeLocation() }
        )
        .disabled(self.viewModel.isApproving)
        .padding(.top, .large2)
        .padding(.bottom, .large)

    }

    @ViewBuilder
    private func approvalActions() -> some View {

        VStack(spacing: self.style.spacing(.small2)) {

            LeafLaunchButton(
                title: String(localized: "I'm \(self.viewModel.minimumAge) or older"),
                icon: .systemImage("chevron.right"),
                iconAlignment: .trailing,
                size: .prominent,
                isEnabled: !self.viewModel.isApproving
            ) { [weak viewModel] in
                viewModel?.approve()
            }

            exitAction()

        }
        .padding(.horizontal, .medium)
        .padding(.top, .small)
        .padding(.bottom, .small)
        .background(self.style.background(.primary))

    }

    @ViewBuilder
    private func exitAction() -> some View {

        Text(String(localized: "Exit"))
            .appFont(with: .SUBTITLE_3)
            .foregroundStyle(self.style.palette(.link))
            .frame(maxWidth: .infinity)
            .frame(minHeight: self.style.spacing(.extraLarge))
            .contentShape(Rectangle())
            .asButton { [weak viewModel] in viewModel?.changeLocation() }
            .disabled(self.viewModel.isApproving)

    }

}

#Preview {

    AgeVerificationScreen(
        viewModel: mockResolve(AgeVerificationViewModel.self)
            .setup(locationId: MockCustomerModels.primaryLocationId)
    )
    .withMockPreviews()

}
