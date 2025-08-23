//
//  BusinessEmployeeDetailsScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 6/24/25.
//

import SwiftUI

struct BusinessEmployeeDetailsScreen: GPView {
    
    @Environment(NavigationService.self) private var navigationService
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var viewModel: BusinessEmployeeDetailsViewModel
    
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
        
    }
    
    private func navBar() -> some View {
        
        let backButton = NavBarButton(style: .back) {
            self.dismiss()
        }
        .asAnyView()
        
        return NavBarView(
            title: "Employee Details",
            leftButtonView: backButton
        )
        
    }
    
    private func contentCards() -> some View {
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.medium)) {
            
            profile()
            locations()
            activities()
            
        }
        .padding(.horizontal, .medium)
        
    }
    
    
    private func profile() -> some View {
        
        Group {
            
            SectionView(title: "Profile", showDivider: true)
            
            AppCardView {
                
                VStack(alignment: .leading) {
                    
                    label(
                        title: self.viewModel.employee?.name ?? "",
                        icon: "person.text.rectangle.fill"
                    )
                    
                    label(
                        title: self.viewModel.employee?.email ?? "",
                        icon: "envelope.fill"
                    )
                    
                }
                
            }
            
        }
        
    }
    
    private func locations() -> some View {
        
        SectionView(title: "Active Locations", showDivider: true)
        
    }
    
    private func activities() -> some View {
        
        SectionView(title: "Activities", showDivider: true) {
            print("Show All Activities")
        }
        
    }
    
    private func label(title: String,
                       icon: String) -> some View {
        
        HStack {
            
            Image(systemName: icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 16, height: 16)
                .foregroundStyle(Style.shared.accent.source())
            
            Text(title)
                .appFont(with: .TITLE_4)
                .foregroundStyle(Style.shared.textColor(.title).source())
            
        }
        
    }
    
}

#Preview {
    
    let viewModel = mockResolve(BusinessEmployeeDetailsViewModel.self)
        .setup(
            businessId: MockModels.ID.business1,
            employeeId: MockModels.ID.employee1
        )
    
    BusinessEmployeeDetailsScreen(viewModel: viewModel)
        .withMockServices()
    
}
