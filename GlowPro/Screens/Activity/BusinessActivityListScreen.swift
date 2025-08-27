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
            config: self.viewModel.emptyStateConfig()
        )
        .safeAreaInset(edge: .bottom) {
            bottomBar()
        }
        .animation(.smooth(duration: 0.3), value: self.viewModel.selectedActivityTypes)
        
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
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.medium)) {
            
            filersView()
            
            ActivitiesView(activities: self.viewModel.filteredActivities)
                .padding(.horizontal, .medium)
            
        }
        
    }
    
    private func filersView() -> some View {
        
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
        .onTapGesture {
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
            
        }
        
    }

}

#Preview {
    
    let viewModel = mockResolve(BusinessActivityListViewModel.self)
        .setup(context: .business(businessId: MockModels.ID.business1))
    
    BusinessActivityListScreen(viewModel: viewModel)
        .withMockServices()
    
}

//
//if !self.viewModel.selectedActivityTypes.isEmpty {
//    
//    Text("Clear Filters")
//        .appFont(with: .BODY_3)
//        .foregroundStyle(Style.shared.background(.error).source())
//        .padding(.small)
//        .background(Style.shared.background(.error).source(opacity: 0.15))
//        .clipShape(.rect(cornerRadius: Style.shared.radius(.extraSmall)))
//        .transition(.move(edge: .leading).combined(with: .opacity))
//        .frame(maxWidth: .infinity, alignment: .leading)
//        .padding(.horizontal, .medium)
//    
//}
