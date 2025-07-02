//
//  ClientDetailsScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 6/19/25.
//

import SwiftUI

struct ClientDetailsScreen: GPView {
    
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var viewModel: ClientDetailsViewModel
    @State private var navigationService = NavigationService()
        
    var body: some View {
        
        AppRootView(
            navigationService: self.$navigationService,
            alertService: self.viewModel.alertService
        ) {
                
            AppHeaderScrollView(horizontalPadding: .none) {
                // N/A
            } scrollViewContent: {
                content()
            }
            // Lifecycle
            
            .onFirstAppear {
                
                self.viewModel
                    .track()
                
                self.viewModel.setup(
                    navigationService: self.navigationService,
                    dismissAction: {
                        dismiss()
                    }
                )
                
            }
            .task {
                
                self.viewModel
                    .loadData()
                
            }
            
        }
        
    }
    
    @ViewBuilder
    private func content() -> some View {
        
        VStack(spacing: 24) {
            
            if let client = viewModel.client {
                
                AppCardView {
                    
                    Text(client.fullName)
                        .appFont(with: .HEADER_H10)
                        .foregroundStyle(Style.shared.textColor(.title).source())
                    
                }
                .asButton {
                    dismiss()
                }
                .padding(.horizontal, .large)
                .transition(.move(edge: .bottom))
                
                actionItems()
                activityFilters()
                activities()
                
            }
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .animation(.smooth(duration: 0.4), value: self.viewModel.client)
        
    }
    
    @ViewBuilder
    private func actionItems() -> some View {
        
        LazyVGrid(columns: [.init(.adaptive(minimum: 80, maximum: 80), spacing: 8, alignment: .center)], spacing: 4) {
            
            actionItem(title: "Notes", icon: "pencil", gradientColors: [.purple, .indigo]) {}
            actionItem(title: "Forms", icon: "text.document.fill", gradientColors: [.green, .mint]) {}
            actionItem(title: "Folders", icon: "folder.fill", gradientColors: [.cyan, .blue]) {}
            actionItem(title: "Forms", icon: "document.fill", gradientColors: [.orange, .red]) {}
            actionItem(title: "Some", icon: "person.fill", gradientColors: [.red, .pink]) {}
            actionItem(title: "Other", icon: "house.fill", gradientColors: [.green, .mint]) {}
            actionItem(title: "Thing", icon: "grid", gradientColors: [.cyan, .blue]) {}
            actionItem(title: "Test", icon: "magnifyingglass", gradientColors: [.purple, .indigo]) {}
            
        }
        .padding(.horizontal, .large)
        
    }
    
    @ViewBuilder
    private func activityFilters() -> some View {
        
        TokenView(
            text: "Test",
            foregroundStyle: .color(.white),
            backgroundStyle: .color(.green)
        )
        .asButton {
            self.viewModel.selectedActivitiesFilter = (self.viewModel.selectedActivitiesFilter == nil) ? "1" : nil
        }
        
    }
    
    @ViewBuilder
    private func activities() -> some View {
        
        let activities: [Activity] = [
            .init(
                id: "1",
                title: "Called Client",
                clientId: "",
                employeeId: "",
                createdAt: Date().addingTimeInterval(-73497493).toISO()
            ),
            .init(
                id: "2",
                title: "Intake Form Filled",
                clientId: "",
                employeeId: "",
                createdAt: Date().addingTimeInterval(-4379743).toISO()
            ),
            .init(
                id: "3",
                title: "Ate At Outback",
                clientId: "",
                employeeId: "",
                createdAt: Date().addingTimeInterval(-4379743).toISO()
            ),
            .init(
                id: "4",
                title: "Did Something Else",
                clientId: "",
                employeeId: "",
                createdAt: Date().toISO()
            ),
            .init(
                id: "5",
                title: "Built Legos",
                clientId: "",
                employeeId: "",
                createdAt: Date().toISO()
            ),
            .init(
                id: "6",
                title: "Ate Some Soup",
                clientId: "",
                employeeId: "",
                createdAt: Date().toISO()
            ),
        ]
        
        ActivitiesView(
            activities: self.viewModel.selectedActivitiesFilter == nil ? activities : activities.suffix(3)
        )
        .padding(.horizontal, .large)
        .animation(.spring, value: self.viewModel.selectedActivitiesFilter)
        
    }
    
    private func actionItem(title: String,
                            icon: String,
                            gradientColors: [Color],
                            action: @escaping () -> Void) -> some View {
        
        VStack {
            
            Image(systemName: icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
            
            Text(title)
                .appFont(with: .TITLE_T4)
            
        }
        .foregroundStyle(Style.shared.textColor(.titleInverted).source())
        .frame(width: 80, height: 80)
        .background(
            LinearGradient(
                colors: gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(.rect(cornerRadius: Style.shared.radius(.medium)))
        .asButton {
            action()
        }
        
    }
    
}

#Preview {
    
    let viewModel = mockResolve(ClientDetailsViewModel.self)
        .setup(clientId: "123")
    
    ClientDetailsScreen(viewModel: viewModel)
        .withMockServices()
    
}
