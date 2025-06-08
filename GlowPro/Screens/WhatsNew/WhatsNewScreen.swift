//
//  WhatsNewScreen.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 3/7/25.
//

import SwiftUI

struct WhatsNewScreen: GPView {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: WhatsNewViewModel
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            Style
                .shared
                .background(.primary)
                .view()
                .ignoresSafeArea()
            
            if let whatsNewItem = viewModel.whatsNewItem {
                content(whatsNewItem: whatsNewItem)
            }
            
        }
        .frame(maxWidth: .infinity)
        .animation(.bouncy, value: self.viewModel.whatsNewItem)
        .presentationBackground(Style.shared.background(.primary).source())
        
        // Done Button
        
        .safeAreaInset(edge: .bottom) {
            
            CommonButton(title: "Done",
                         titleColor: Style.shared.textColor(.titleInverted)) {
                
                dismiss()
                
            }
            .padding(.horizontal, .large)
            
        }
        
        // Lifecycle
        
        .onFirstAppear {
            
            self.viewModel
                .track()
            
        }
        
    }
    
    private func content(whatsNewItem: WhatsNewItem) -> some View {
        
        ScrollView {
            
            VStack(spacing: Style.shared.spacing(.extraLarge)) {
                
                // Header
                
                headerView(whatsNewItem: whatsNewItem)
                
                // Item List
                
                itemList(items: whatsNewItem.items)
                
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .top
            )
            .padding(.bottom, .custom(64))
            
        }
        .scrollBounceBehavior(.basedOnSize)
        
    }
    
    private func headerView(whatsNewItem: WhatsNewItem) -> some View {
        
        VStack(spacing: 16) {
            
            Image(.appIcon)
                .resizable()
                .frame(width: 85, height: 85)
                .clipShape(.rect(cornerRadius: 24))
                .padding(.top, 32)
            
            VStack {
                
                Text("What's New")
                    .foregroundStyle(Style.shared.textColor(.title).source())
                    .appFont(with: .HEADER_H1)
                    .multilineTextAlignment(.center)
                
                Text("Version: \(whatsNewItem.version.description)")
                    .foregroundStyle(Style.shared.textColor(.body).source())
                    .appFont(with: .BODY_B1)
                    .multilineTextAlignment(.center)
                
            }
            
        }
        
    }
    
    private func itemList(items: [WhatsNewItem.Item]) -> some View {
        
        VStack(spacing: Style.shared.spacing(.medium)) {
            
            ForEach(items) { item in
                itemView(item)
            }
            
        }
        .padding(.horizontal, .large)
        
    }
    
    private func itemView(_ item: WhatsNewItem.Item) -> some View {
        
        AppOutlineCardView {
            
            HStack(spacing: 16) {
                
                Image(systemName: item.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                    .foregroundStyle(item.foregroundStyle.source())
                
                VStack(alignment: .leading, spacing: Style.shared.spacing(.custom(2))) {
                    
                    Text(item.title)
                        .foregroundStyle(Style.shared.textColor(.title).source())
                        .appFont(with: .TITLE_T6)
                    
                    Text(item.message)
                        .foregroundStyle(Style.shared.textColor(.body).source())
                        .appFont(with: .BODY_B5)
                    
                }
                
            }
            
        }
        
    }
    
}

#Preview {
    
    let viewModel = mockResolve(WhatsNewViewModel.self)
        .setup(whatsNewItem: Constants.WhatsNewItems.items.last!)
    
    WhatsNewScreen(viewModel: viewModel)
        .withMockServices()
    
}
