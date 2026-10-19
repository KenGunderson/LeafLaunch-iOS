import SwiftUI

struct LocationListScreen: GPView {

    @Environment(\.style) private var style
    @Environment(NavigationService.self) private var navigationService

    @StateObject private var viewModel: LocationListViewModel

    init(viewModel: LocationListViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {

        LLAppHeaderScrollView {
            navHeader()
        } scrollViewContent: {
            content()
        }
        .scrollDismissesKeyboard(.interactively)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            flowActions()
        }
        .interactiveDismissDisabled(!self.viewModel.canDismiss)
        .animation(.bouncy, value: self.viewModel.step)
        .onFirstAppear { [weak viewModel] in

            viewModel?.setup(navigationService: self.navigationService)
            viewModel?.handleFirstAppear()

        }
        .task(id: self.viewModel.step) { [weak viewModel] in
            viewModel?.loadData(showHud: true)
        }
        .onDisappear { [weak viewModel] in viewModel?.cancelLocationSelectionWork() }

    }

    @ViewBuilder
    private func navHeader() -> some View {

        switch self.viewModel.step {
        case .locationSelection:

            StoreNavHeader(
                configuration: self.viewModel.configuration,
                subtitle: String(localized: "Choose A Location"),
                onDismiss: self.viewModel.canDismiss ? { [weak viewModel] in viewModel?.dismiss() } : nil
            )
            .transition(.blurReplace)
            .safeAreaPadding(.top, self.style.spacing(.medium))

        case .ageVerification:

            StoreNavHeader(
                configuration: self.viewModel.configuration,
                subtitle: nil,
                onBack: { [weak viewModel] in viewModel?.changeLocation() }
            )
            .safeAreaPadding(.top, self.style.spacing(.medium))
            .transition(.blurReplace)
            .disabled(self.viewModel.isApproving)

        }

    }

    @ViewBuilder
    private func content() -> some View {

        Group {

            switch self.viewModel.step {
            case .locationSelection:

                locationSelection()
                    .transition(.blurReplace)

            case .ageVerification:

                ageVerification()
                    .transition(.blurReplace)
            }

        }

    }

    @ViewBuilder
    private func locationSelection() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.large)) {

            LocationSearchControls(viewModel: self.viewModel)
            locationResults()
            retryAction()

        }
        .padding(.bottom, .large)

    }

    @ViewBuilder
    private func ageVerification() -> some View {

        AgeVerificationConsentView(
            minimumAge: self.viewModel.minimumAge,
            locationDetails: self.viewModel.ageVerificationDetails,
            changeLocationAction: { [weak viewModel] in viewModel?.changeLocation() }
        )
        .disabled(self.viewModel.isApproving)
        .padding(.top, .large2)
        .padding(.bottom, .large)

    }

    @ViewBuilder
    private func locationResults() -> some View {

        if self.viewModel.locations.isEmpty {

            CommerceEmptyState(
                systemImage: "mappin.and.ellipse",
                title: String(localized: "No Locations Available"),
                message: String(localized: "There are no available locations.")
            )

        } else if self.viewModel.filteredLocations.isEmpty {

            VStack(spacing: self.style.spacing(.small)) {

                CommerceEmptyState(
                    systemImage: "magnifyingglass",
                    title: String(localized: "No Stores Found"),
                    message: String(localized: "Try another city, ZIP code or store name.")
                )

                LeafLaunchButton(title: String(localized: "Clear Search")) { [weak viewModel] in
                    viewModel?.clearSearch()
                }

            }

        } else {
            locations()
        }

    }

    @ViewBuilder
    private func locations() -> some View {

        LazyVStack(spacing: self.style.spacing(.small2)) {

            ForEach(self.viewModel.filteredLocations, id: \.id) { location in
                locationRow(location)
            }

        }

    }

    @ViewBuilder
    private func locationRow(_ location: BootstrapLocation) -> some View {

        LocationSelectionCard(
            location: location,
            details: self.viewModel.locationDetails[location.id],
            isLoading: self.viewModel.isLoading,
            isSelected: self.viewModel.selectedLocationId == location.id
        ) { [weak viewModel] in
            viewModel?.selectLocation(id: location.id)
        }
        .disabled(self.viewModel.isContinuing)

    }

    @ViewBuilder
    private func flowActions() -> some View {

        Group {

            switch self.viewModel.step {
            case .locationSelection:

                selectionFooter()
                    .transition(.blurReplace)

            case .ageVerification:

                approvalActions()
                    .transition(.blurReplace)
            }

        }
        .transition(.blurReplace)

    }

    @ViewBuilder
    private func selectionFooter() -> some View {

        LocationSelectionFooter(
            isEnabled: self.viewModel.canContinue
        ) { [weak viewModel] in
            viewModel?.continueToLocation()
        }

    }

    @ViewBuilder
    private func approvalActions() -> some View {

        VStack(spacing: self.style.spacing(.small2)) {

            LeafLaunchButton(
                title: String(localized: "I'm \(self.viewModel.minimumAge) Or Older"),
                icon: .systemImage("chevron.right"),
                iconAlignment: .trailing,
                size: .prominent,
                isEnabled: !self.viewModel.isApproving
            ) { [weak viewModel] in
                viewModel?.approveAgeVerification()
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

    @ViewBuilder
    private func retryAction() -> some View {

        if !self.viewModel.failedLocationIds.isEmpty {

            LeafLaunchButton(
                title: String(localized: "Retry Location Details"),
                icon: .systemImage("arrow.clockwise")
            ) { [weak viewModel] in
                viewModel?.loadData(showHud: true)
            }
            .disabled(self.viewModel.isLoading || self.viewModel.isContinuing)

        }

    }

}

#Preview {

    LocationListScreen(viewModel: mockResolve(LocationListViewModel.self))
        .withMockPreviews()

}
