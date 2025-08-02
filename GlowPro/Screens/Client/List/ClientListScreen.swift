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

    }
    
    private func navBar() -> some View {
        
        let backButton = BackButton(backgroundColor: .color(.clear)) {
            self.viewModel.dismiss()
        }
        .asAnyView()
        
        let plusButton = CircularIconView(
            foregroundColor: .color(.black),
            backgroundColor: .color(.clear),
            imageSource: .systemImage("plus"),
            size: 32
        )
        .asButton {
            print("ADD NEW CLIENT")
        }
        .asAnyView()
        
        return NavBarView(
            title: "Client List",
            leftButtonView: backButton,
            rightButtonView: plusButton
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
