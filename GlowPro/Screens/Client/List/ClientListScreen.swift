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
    
    @FocusState private var isFocused: Bool
        
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
                    .loadData(showHud: self.viewModel.isFirstLoad)
                
            }
        
        // Animations
        
            .animation(.smooth, value: self.viewModel.filteredGroupedClientsDict)
            .animation(.smooth, value: self.viewModel.groupedClientsDict)
        
        // Tap
        
            .onTapGesture {
                self.isFocused = false
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
        
        let dict = self.viewModel.filteredGroupedClientsDict
        
        VStack {
            
            if !self.viewModel.groupedClientsDict.isEmpty {
                
                textField()
                    .transition(.move(edge: .top).combined(with: .opacity))
                
            }
            
            ForEach(dict.keys.sorted(), id: \.self) { letter in
                
                section(
                    title: "\(letter)",
                    clients: dict[letter] ?? []
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
                
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
                            extraInformationItem(icon: .image(.iconMail, renderingMode: .template))
                        }
                        
                        if client.phoneNumber != nil {
                            extraInformationItem(icon: .image(.iconPhone, renderingMode: .template))
                        }
                        
                        if client.dateOfBirth != nil {
                            extraInformationItem(icon: .image(.iconCake, renderingMode: .template))
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
    
    private func textField() -> some View {
        
        return TextField(
            "",
            text: self.$viewModel.queryString,
            prompt: Text("Search for a client...").foregroundStyle(Style.shared.textColor(.placeholder).source())
        )
            .foregroundColor(.red)
            .appTextFieldStyle(
                text: self.$viewModel.queryString.wrappedValue,
                icon: .systemImage("magnifyingglass"),
                isFocused: isFocused,
                foregroundColor: Style.shared.textColor(.title),
                textFieldFont: .BODY_3,
                shadow: .none,
                leadingSpacing: .small2
            )
            .focused(self.$isFocused)
            .keyboardType(.default)
            .textContentType(.name)
            .submitLabel(.search)
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled(true)
            .appOnTapGesture {
                self.isFocused = true
            }
        
    }
    
}

#Preview {
    
    let viewModel = mockResolve(ClientListViewModel.self)
        .setup(context: .business(businessId: MockModels.ID.business1))
    
    ClientListScreen(viewModel: viewModel)
        .withMockServices()
    
}
