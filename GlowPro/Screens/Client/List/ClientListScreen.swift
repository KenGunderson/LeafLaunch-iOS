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
    
    private func clientList() -> some View {
        
        let dict = self.viewModel.groupedClientsDict
        
        return ForEach(dict.keys.sorted(), id: \.self) { letter in
            
            section(
                title: "\(letter)",
                clients: dict[letter] ?? []
            )
            
        }
        
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
            
            LazyVStack(alignment: .leading, spacing: Style.shared.spacing(.small)) {
                
                Text(client.fullName)
                    .appFont(with: .TITLE_T6)
                    .foregroundStyle(Style.shared.textColor(.title).source())
                
                if client.hasEmailPhoneOrBirthday {
                    
                    VStack(alignment: .leading, spacing: Style.shared.spacing(.extraSmall)) {
                        
                        if let email = client.email {
                            
                            extraInformationItem(
                                text: email,
                                icon: "envelope.fill"
                            )
                            
                        }
                        
                        if let phone = client.phone {
                            
                            extraInformationItem(
                                text: phone,
                                icon: "phone.fill"
                            )
                            
                        }
                        
                        if let birthDate = client.birthDate {
                            
                            let formattedDate = birthDate.formatted(date: .abbreviated, time: .omitted)
                            
                            extraInformationItem(
                                text: formattedDate,
                                icon: "birthday.cake.fill"
                            )
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    private func extraInformationItem(text: String,
                                      icon: String) -> some View {
        
        HStack {
            
            Image(systemName: icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 16, height: 16)
            
            Text(text)
                .appFont(with: .BODY_B5)
            
        }
        .foregroundStyle(Style.shared.textColor(.body).source())
        
    }
    
}

#Preview {
    
    let viewModel = mockResolve(ClientListViewModel.self)
    
    ClientListScreen(viewModel: viewModel)
        .withMockServices()
    
}
