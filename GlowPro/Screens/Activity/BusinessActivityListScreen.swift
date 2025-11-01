//
//  BusinessActivityListScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/24/25.
//

import SwiftUI

struct BusinessActivityListScreen: GPView {
    
    @Environment(NavigationService.self) private var navigationService
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var viewModel: BusinessActivityListViewModel
    
    var body: some View {
        
        content()
        
        // Lifecycle
        
            .onFirstAppear {
                
                self.viewModel
                    .track()
                
                self.viewModel
                    .setup(navigationService: self.navigationService)
                
            }
            .task {
                
                self.viewModel
                    .loadData()
                
            }
                
    }
    
    private func content() -> some View {
        
        AppHeaderScrollView(horizontalPadding: .none) {
            navBar()
        } scrollViewContent: {
            contentCards()
        }
        .emptyStateOverlay(
            shouldShow: self.viewModel.shouldShowEmptyState,
            config: self.viewModel.emptyStateConfig(),
            transition: .move(edge: .bottom).combined(with: .opacity),
            animation: .spring
        )
        .safeAreaInset(edge: .bottom) {
            bottomBar()
        }
        
    }
    
    private func navBar() -> some View {
        
        let backButton = NavBarButton(style: .back) {
            self.dismiss()
        }
        .asAnyView()
        
        return NavBarView(
            title: "Activities",
            leftButtonView: backButton
        )
        
    }
    
    private func contentCards() -> some View {
        
        VStack(spacing: Style.shared.spacing(.medium)) {
            
            filtersView()
            
            LazyVStack(alignment: .leading, spacing: Style.shared.spacing(.medium)) {
                
                LazyActivitiesView(activities: self.viewModel.activities) {
                    
                    self.viewModel
                        .loadData()
                    
                }
                .padding(.horizontal, .medium)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        
    }
    
    private func filtersView() -> some View {
        
        ScrollView(.horizontal) {
            
            HStack {
                
                ForEach(ActivityType.allCases, id: \.rawValue) { activityType in
                    filterView(activityType)
                }
                
            }
            
        }
        .safeAreaPadding(.horizontal, Style.shared.spacing(.medium))
        
    }
    
    private func filterView(_ activityType: ActivityType) -> some View {
        
        let isSelected = self.viewModel.selectedActivityTypes.contains(activityType)
        
        return TokenView(
            text: activityType.displayName,
            foregroundStyle: isSelected ? Style.shared.textColor(.button) : Style.shared.textColor(.title),
            backgroundStyle: isSelected ? Style.shared.accent : .color(.clear),
            verticalPadding: .small,
            clipShape: .init(.rect(cornerRadius: Style.shared.radius(.extraSmall)))
        )
        .appBorder(
            cornerRadius: .extraSmall,
            color: isSelected ? Style.shared.accent : Style.shared.background(.border),
            lineWidth: 1.5
        )
        .appShadow(.subtle)
        .appOnTapGesture {
            self.viewModel.set(activityType: activityType)
        }
        
    }
    
    @ViewBuilder
    private func bottomBar() -> some View {
        
        if !self.viewModel.selectedActivityTypes.isEmpty {
            
            CommonButton(
                title: "Clear All Filters",
                titleColor: Style.shared.background(.error),
                icon: .systemImage("xmark"),
                backgroundStyle: .color(Style.shared.background(.error).asColor!.opacity(0.15))
            ) {
                
                self.viewModel
                    .clearFilters()
                
            }
            .padding(.horizontal, .extraLarge)
            .transition(
                .move(edge: .bottom)
                .combined(with: .opacity)
            )
            .frame(maxWidth: .infinity)
            .background(Style.shared.background(.primary).source())
            
        }
        
    }

}

#Preview {
    
    let viewModel = mockResolve(BusinessActivityListViewModel.self)
        .setup(context: .business(businessId: MockModels.ID.business1))
    
    BusinessActivityListScreen(viewModel: viewModel)
        .withMockServices()
    
}
