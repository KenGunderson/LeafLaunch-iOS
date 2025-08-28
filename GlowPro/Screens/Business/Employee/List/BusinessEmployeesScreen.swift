//
//  BusinessEmployeesScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 6/24/25.
//

import SwiftUI

struct BusinessEmployeesScreen: GPView {
    
    @Environment(NavigationService.self) private var navigationService
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var viewModel: BusinessEmployeesViewModel
    
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
        
    }
    
    private func navBar() -> some View {
        
        let backButton = NavBarButton(style: .back) {
            self.dismiss()
        }
        .asAnyView()
        
        let plusButton = NavBarButton(style: .plus) {
            
            self.navigationService
                .push(.business(.businessEmployeesInvite(
                    businessId: self.viewModel.businessId
                )))
            
        }
        .asAnyView()
        
        return NavBarView(
            title: "Employees",
            leftButtonView: backButton,
            rightButtonView: self.viewModel.isOwnerOrManager ? plusButton : nil
        )
        
    }
    
    
    private func contentCards() -> some View {
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.medium)) {
            
            ForEach(self.viewModel.employees, id: \.id) { employee in
                
                AppCardView {
                    
                    Text(employee.name)
                        .appFont(with: .TITLE_5)
                        .foregroundStyle(Style.shared.textColor(.title).source())
                    
                }
                .asButton {
                    
                    self.viewModel
                        .selectEmployee(employee)
                    
                }
                
            }
            
        }
        .padding(.horizontal, .medium)
        
    }
    
}

#Preview {
    
    let viewModel = mockResolve(BusinessEmployeesViewModel.self)
        .setup(
            businessId: MockModels.ID.business1,
            context: .business(businessId: MockModels.ID.business1)
        )
    
    BusinessEmployeesScreen(viewModel: viewModel)
        .withMockServices()
    
}
