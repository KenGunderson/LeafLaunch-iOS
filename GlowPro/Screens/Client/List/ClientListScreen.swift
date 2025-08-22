//
//  ClientListScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 6/19/25.
//

import SwiftUI

struct ClientListScreen: GPView {
    
    @StateObject var viewModel: ClientListViewModel
    @Environment(NavigationService.self) private var navigationService
        
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
        
        AppHeaderScrollView(backgroundStyle: Style.shared.background(.primary)) {
            navBar()
        } scrollViewContent: {
            clientList()
        }
        .emptyStateOverlay(
            shouldShow: self.viewModel.shouldShowEmptyState,
            config: self.viewModel.emptyStateConfig()
        )

    }
    
    private func navBar() -> some View {
        
        let backButton = NavBarButton(style: .back) {
            self.viewModel.dismiss()
        }
        .asAnyView()
        
        let plusButton = NavBarButton(style: .plus) {
            
            switch self.viewModel.context {
            case .location(let locationId):
                
                self.navigationService
                    .push(.client(.clientCreate(locationId: locationId)))
                
            default: break
            }
            
        }
        .asAnyView()
        
        return NavBarView(
            title: "Client List",
            leftButtonView: backButton,
            rightButtonView: self.viewModel.isLocationContext ? plusButton : nil
        )
        
    }
    
    @ViewBuilder
    private func clientList() -> some View {
        
        let dict = self.viewModel.groupedClientsDict
        
        VStack {
            
            ForEach(dict.keys.sorted(), id: \.self) { letter in
                
                section(
                    title: "\(letter)",
                    clients: dict[letter] ?? []
                )
                
            }
            
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, .custom(86))
        
    }
    
    private func section(title: String,
                         clients: [Client]) -> some View {
        
        LazyVStack(alignment: .leading, spacing: Style.shared.spacing(.small)) {
            
            Text(title)
                .appFont(with: .HEADER_3)
                .foregroundStyle(Style.shared.textColor(.title).source())
            
            ForEach(clients, id: \.id) { client in
                clientItem(client)
            }
            
        }
        
    }
    
    private func clientItem(_ client: Client) -> some View {
        
        AppCardView(shadow: .subtle) {
            
            HStack(spacing: Style.shared.spacing(.small)) {
                
                Text(client.fullName)
                    .appFont(with: .TITLE_5)
                    .foregroundStyle(Style.shared.textColor(.title).source())
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if client.hasEmailPhoneOrBirthday {
                    
                    HStack(spacing: Style.shared.spacing(.small)) {
                        
                        if client.email != nil {
                            extraInformationItem(icon: .image(.iconMail))
                        }
                        
                        if client.phone != nil {
                            extraInformationItem(icon: .image(.iconPhone))
                        }
                        
                        if client.birthDate != nil {
                            extraInformationItem(icon: .image(.iconCake))
                        }
                            
                    }
                    
                }
                
                Image(systemName: "chevron.right")
                    .foregroundStyle(Style.shared.textColor(.title).source())
                    .opacity(0.5)
                
            }
            
        }
        .asButton {
            
            self.viewModel
                .selectClient(client)
            
        }
        
    }
    
    private func extraInformationItem(icon: ImageSource) -> some View {
        
        icon
            .view(renderingMode: .template)
            .aspectRatio(contentMode: .fit)
            .frame(width: 16, height: 16)
            .foregroundStyle(Style.shared.textColor(.body).source())
        
    }
    
}

#Preview {
    
    let viewModel = mockResolve(ClientListViewModel.self)
    
    ClientListScreen(viewModel: viewModel)
        .withMockServices()
    
}
