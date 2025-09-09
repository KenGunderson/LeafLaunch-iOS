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
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.medium)) {
            
            profile()
                .padding(.horizontal, .medium)
            
            media()
            
            activities()
                .padding(.horizontal, .medium)
            
        }
        
    }
    
    
    private func profile() -> some View {
        
        Group {
            
            SectionView(leadingTitle: "Profile", showDivider: true)
            
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
    
    @ViewBuilder
    private func media() -> some View {
        
        VStack(spacing: Style.shared.spacing(.small2)) {
            
            SectionView(leadingTitle: "Media", showDivider: true) {
                
                self.navigationService.push(.media(
                    .gallery(.employee(employeeId: self.viewModel.employeeId))
                ))
                
            }
            .padding(.horizontal, .medium)
            
            ScrollView(.horizontal) {
                
                LazyHStack {
                    
                    let placeholderView = RoundedRectangle(cornerRadius: Style.shared.radius(.small))
                        .fill(Style.shared.background(.quaternary).source())
                        .overlay {
                            
                            AppLoadingView(style: .circleRunner(
                                color: Style.shared.background(.primary),
                                size: 24
                            ))
                            
                        }
                        .asAnyView()
                    
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
    
    private func activities() -> some View {
        
        VStack(spacing: Style.shared.spacing(.small2)) {
            
            SectionView(leadingTitle: "Activities", showDivider: true) {
                
                self.navigationService.push(.business(.businessActivitiesList(
                    context: .employee(employeeId: self.viewModel.employeeId)
                )))
                
            }
            
            ActivitiesView(activities: self.viewModel.activities)
            
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
