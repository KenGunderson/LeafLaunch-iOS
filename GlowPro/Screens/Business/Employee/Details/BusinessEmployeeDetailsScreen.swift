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
        
        let deleteButton = NavBarButton(style: .trash) {
            
            self.viewModel
                .presentDeleteEmployeeAlert()
            
        }
        .asAnyView()
        
        return NavBarView(
            title: "Employee Details",
            leftButtonView: backButton,
            rightButtonView: self.viewModel.isOwnerOrManager ? deleteButton : nil
        )
        
    }
    
    private func contentCards() -> some View {
        
        VStack(alignment: .leading,
               spacing: Style.shared.spacing(.medium)) {
            
            profile()
                .padding(.horizontal, .medium)
            
            activeLocations()
                .padding(.horizontal, .medium)
            
            media()
            
            activities()
                .padding(.horizontal, .medium)
            
        }
        
    }
    
    
    @ViewBuilder
    private func profile() -> some View {
        
        VStack(spacing: Style.shared.spacing(.small)) {
            
            SectionView(leadingTitle: "Profile", showDivider: true)
            
            AppCardView(shadow: .subtle) {
                
                VStack(alignment: .leading) {
                    
                    LineItemView(
                        title: "Name:",
                        value: self.viewModel.employee?.name ?? "",
                        systemName: "person.text.rectangle.fill"
                    )
                    
                    LineItemView(
                        title: "Email:",
                        value: self.viewModel.employee?.email ?? "",
                        systemName: "envelope.fill"
                    )
                    
                }
                
            }
            
        }
        
    }
    
    @ViewBuilder
    private func media() -> some View {
        
        VStack(spacing: Style.shared.spacing(.small)) {
            
            SectionView(leadingTitle: "Media", showDivider: true) {
                
                self.navigationService.push(.media(
                    .gallery(
                        mediaContext: .employee(employeeId: self.viewModel.employeeId),
                        mediaSelectionContext: .preview
                    )))
                
            }
            .padding(.horizontal, .medium)
            
            ScrollView(.horizontal) {
                
                LazyHStack {
                    
                    let placeholderView = PlaceholderView().asAnyView()
                    
                    ForEach(Array(self.viewModel.media.prefix(10)), id: \.id) { media in
                        
                        ImageSource.remote(
                            url: media.url,
                            placeholder: placeholderView,
                        )
                        .view(shouldResize: false)
                        .aspectRatio(1, contentMode: .fit)
                        .frame(width: 64)
                        .cornerRadius(.small)
                        
                    }
                    
                }
                .safeAreaPadding(.horizontal, Style.shared.spacing(.medium))
                
            }
            
        }
        
    }
    
    @ViewBuilder
    private func activities() -> some View {
        
        VStack(spacing: Style.shared.spacing(.small)) {
            
            SectionView(leadingTitle: "Activities", showDivider: true) {
                
                self.navigationService.push(.business(.businessActivitiesList(
                    context: .employee(employeeId: self.viewModel.employeeId)
                )))
                
            }
            
            ActivitiesView(activities: Array(self.viewModel.activities.prefix(10)))
            
        }
        
    }
    
    @ViewBuilder
    private func activeLocations() -> some View {
        
        VStack(spacing: Style.shared.spacing(.small)) {
            
            SectionView(
                leadingTitle: "Active Locations",
                showDivider: true
            )
            
            ForEach(self.viewModel.activeLocations, id: \.self) { location in
                activeLocation(location)
            }
            
        }
        
    }
    
    private func activeLocation(_ activeLocation: Workspace.RoleLocation) -> some View {
        
        AppCardView(shadow: .subtle) {
            
            VStack(alignment: .leading) {
                
                LineItemView(
                    title: "Location",
                    value: activeLocation.location.name,
                    systemName: "pin.fill"
                )
                
                LineItemView(
                    title: "Role",
                    value: activeLocation.role.description,
                    systemName: "person.text.rectangle.fill"
                )
                
            }
            
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
