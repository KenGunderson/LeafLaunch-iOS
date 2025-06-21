//
//  ClientListScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 6/19/25.
//

import SwiftUI

struct ClientListScreen: View {
    
    @StateObject var viewModel: ClientListViewModel
    @Environment(TabBarNavigationService.self) private var tabBarNavigationService
        
    var body: some View {
        
        content()
        
        // Lifecycle
        
            .onFirstAppear {
                
                self.viewModel
                    .track()
                
                self.viewModel
                    .setup(tabBarNavigationService: self.tabBarNavigationService)
                
            }
            .onAppear {
                
                self.tabBarNavigationService
                    .shouldShowTabBar(false)
                
            }
            .task {
                
                self.viewModel
                    .loadData()
                
            }
        
    }
    
    private func content() -> some View {
        
        AppHeaderScrollView {
            navBar()
        } scrollViewContent: {
            clientList()
        }

    }
    
    private func navBar() -> some View {
        
        NavBarView(
            title: "Client List",
            leftButtonView: (
                BackButton {
                    self.viewModel.dismiss()
                }
            ).asAnyView()
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
        .padding(.bottom, .custom(86))
        
    }
    
    private func section(title: String,
                         clients: [Client]) -> some View {
        
        LazyVStack(alignment: .leading, spacing: Style.shared.spacing(.small)) {
            
            Text(title)
                .appFont(with: .HEADER_H6)
                .foregroundStyle(Style.shared.textColor(.title).source())
            
            ForEach(clients, id: \.id) { client in
                clientItem(client)
            }
            
        }
        
    }
    
    private func clientItem(_ client: Client) -> some View {
        
        AppCardView {
            
            HStack(spacing: Style.shared.spacing(.small)) {
                
                Text(client.fullName)
                    .appFont(with: .TITLE_T6)
                    .foregroundStyle(Style.shared.textColor(.title).source())
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if client.hasEmailPhoneOrBirthday {
                    
                    HStack(spacing: Style.shared.spacing(.small)) {
                        
                        if client.email != nil {
                            extraInformationItem(icon: "envelope.fill")
                        }
                        
                        if client.phone != nil {
                            extraInformationItem(icon: "phone.fill")
                        }
                        
                        if client.birthDate != nil {
                            extraInformationItem(icon: "birthday.cake.fill")
                        }
                            
                    }
                    
                }
                
            }
            
        }
        .asButton {
            
            self.viewModel
                .selectClient(client)
            
        }
        
    }
    
    private func extraInformationItem(icon: String) -> some View {
        
        Image(systemName: icon)
            .resizable()
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
