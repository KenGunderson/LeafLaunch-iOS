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
        
        AppBaseView {
            
            if let whatsNewItem = viewModel.whatsNewItem {
                content(whatsNewItem: whatsNewItem)
            }
            
        }
        .frame(maxWidth: .infinity)
        .animation(.bouncy, value: self.viewModel.whatsNewItem)
        
        // Done Button
        
        .safeAreaInset(edge: .bottom) {
            
            CommonButton(title: "Done") {
                dismiss()
            }
            .padding(.horizontal, .large)
            
        }
        
        // Lifecycle
        
        .onFirstAppear { [weak viewModel] in
            
            viewModel?
                .track()
            
        }
        
    }
    
    private func content(whatsNewItem: WhatsNewItem) -> some View {
        
        ScrollView {
            
            VStack(spacing: Style.shared.spacing(.large)) {
                
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
            .padding(.bottom, .extraLarge2)
            
        }
        .scrollBounceBehavior(.basedOnSize)
        
    }
    
    private func headerView(whatsNewItem: WhatsNewItem) -> some View {
        
        VStack(spacing: Style.shared.spacing(.medium)) {
            
            Image(.appIcon)
                .resizable()
                .frame(width: 85, height: 85)
                .clipShape(.rect(cornerRadius: 24))
                .padding(.top, 32)
                .appShadow(.subtle)
            
            VStack {
                
                Text("What's New")
                    .foregroundStyle(Style.shared.textColor(.title).source())
                    .appFont(with: .BILLBOARD_1)
                    .multilineTextAlignment(.center)
                
                Text("Version: \(whatsNewItem.version.description)")
                    .foregroundStyle(Style.shared.textColor(.body).source())
                    .appFont(with: .BODY_1)
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
        
        AppOutlineCardView(outlineColor: .background(.quinary)) {
            
            HStack(spacing: 16) {
                
                Image(systemName: item.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                    .foregroundStyle(item.foregroundStyle.source())
                
                VStack(alignment: .leading, spacing: 2) {
                    
                    Text(item.title)
                        .foregroundStyle(Style.shared.textColor(.title).source())
                        .appFont(with: .TITLE_4)
                    
                    Text(item.message)
                        .foregroundStyle(Style.shared.textColor(.body).source())
                        .appFont(with: .BODY_2)
                    
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
