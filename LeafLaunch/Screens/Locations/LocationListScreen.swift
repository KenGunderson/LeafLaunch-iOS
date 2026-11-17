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
        .safeAreaInset(
            edge: .bottom,
            spacing: 0
        ) {
            flowActions()
        }
        .interactiveDismissDisabled(!self.viewModel.canDismiss)
        .animation(
            .bouncy,
            value: self.viewModel.step
        )
        .onFirstAppear { [weak viewModel] in
            
            viewModel?.setup(navigationService: self.navigationService)
            viewModel?.handleFirstAppear()
            
        }
        .task(id: self.viewModel.step) { [weak viewModel] in
            viewModel?.loadData(showHud: self.viewModel.isFirstLoad)
        }
        .onDisappear { [weak viewModel] in viewModel?.cancelLocationSelectionWork() }
        
    }
    
    @ContentBuilder
    private func navHeader() -> some View {
        
        switch self.viewModel.step {
        case .locationSelection:
            
            StoreNavHeader(
                configuration: self.viewModel.configuration,
                subtitle: String(localized: "Choose A Location"),
                onDismiss: self.viewModel.canDismiss ? { [weak viewModel] in viewModel?.dismiss() } : nil
            )
            .transition(.blurReplace)
            .safeAreaPadding(
                .top,
                self.style.spacing(LLSpacing.listRow)
            )
            
        case .ageVerification:
            
            StoreNavHeader(
                configuration: self.viewModel.configuration,
                subtitle: String(localized: "Age Confirmation"),
            )
            .safeAreaPadding(
                .top,
                self.style.spacing(LLSpacing.listRow)
            )
            .transition(.blurReplace)
            .disabled(self.viewModel.isApproving)
        }
        
    }
    
    @ContentBuilder
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
    
    @ContentBuilder
    private func locationSelection() -> some View {
        
        VStack(
            alignment: .leading,
            spacing: self.style.spacing(LLSpacing.content)
        ) {
            
            LocationSearchControls(viewModel: self.viewModel)
            locationResults()
            retryAction()
            
        }
        .runePadding(.bottom, LLSpacing.content)
        
    }
    
    @ContentBuilder
    private func ageVerification() -> some View {

        AgeVerificationConsentView(
            minimumAge: self.viewModel.minimumAge,
            locationDetails: self.viewModel.ageVerificationDetails,
            changeLocationAction: { [weak viewModel] in viewModel?.changeLocation() }
        )
        .disabled(self.viewModel.isApproving)
        .runePadding(.top, LLSpacing.hero)
        .runePadding(.bottom, LLSpacing.content)
        
    }
    
    @ContentBuilder
    private func locationResults() -> some View {
        
        if self.viewModel.locations.isEmpty && self.viewModel.isFirstLoad {
            
            ProgressView()
                .frame(maxWidth: .infinity)
            
        } else if self.viewModel.locations.isEmpty {
            
            CommerceEmptyState(
                systemImage: "mappin.and.ellipse",
                title: String(localized: "No Locations Available"),
                message: String(localized: "There are no available locations.")
            )
            
        } else if self.viewModel.filteredLocations.isEmpty {
            
            VStack(spacing: self.style.spacing(LLSpacing.groupedContent)) {
                
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
    
    @ContentBuilder
    private func locations() -> some View {
        
        LazyVStack(spacing: self.style.spacing(LLSpacing.cardContent)) {
            
            ForEach(self.viewModel.filteredLocations, id: \.id) { location in
                locationRow(location)
            }
            
        }
        
    }
    
    @ContentBuilder
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
    
    @ContentBuilder
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
        .runePadding(.horizontal, LLSpacing.pageInset)
        .runePadding(.top, LLSpacing.groupedContent)
        .runeBackground(.secondary)
        .overlay(alignment: .top) {
            LLDivider()
        }
        .geometryGroup()
        .compositingGroup()
        .transition(.blurReplace)
        
    }
    
    @ContentBuilder
    private func selectionFooter() -> some View {
        
        LocationSelectionFooter(
            isEnabled: self.viewModel.canContinue
        ) { [weak viewModel] in
            viewModel?.continueToLocation()
        }
        
    }
    
    @ContentBuilder
    private func approvalActions() -> some View {
        
        VStack(spacing: self.style.spacing(LLSpacing.metadata)) {
            
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
        
    }
    
    @ContentBuilder
    private func exitAction() -> some View {
        
        Text(String(localized: "Exit"))
            .runeFont(with: .SUBTITLE_3)
            .foregroundStyle(RNColorSource.palette(.link))
            .frame(maxWidth: .infinity)
            .frame(minHeight: self.style.spacing(.extraLarge))
            .contentShape(Rectangle())
            .runeAsButton { [weak viewModel] in viewModel?.changeLocation() }
            .disabled(self.viewModel.isApproving)
        
    }
    
    @ContentBuilder
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
