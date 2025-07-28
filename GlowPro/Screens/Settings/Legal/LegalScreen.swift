//
//  LegalScreen.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 1/23/25.
//

import SwiftUI
import Charts

struct LegalScreen: View {
    
    @StateObject var viewModel: LegalViewModel
    @Environment(NavigationService.self) private var navigationService
            
    var body: some View {
        
        AppHeaderScrollView {
            headerView()
        } scrollViewContent: {
            content()
        }
        
        // Lifecycle
        
        .onFirstAppear {
            
            self.viewModel
                .track()
            
            self.viewModel
                .loadData()
            
            self.viewModel
                .setup(navigationService: self.navigationService)
            
        }

    }
    
    @ViewBuilder
    private func headerView() -> some View {
        
        NavBarView(
            title: self.viewModel.context.displayName,
            leftButtonView: (
                BackButton {
                    self.viewModel.dismiss()
                }
            ).asAnyView()
        )
        
    }
    
    private func content() -> some View {
        
        let items = self.viewModel.legalItems
        
        return VStack(alignment: .leading) {
            
            if !items.isEmpty {
                
                VStack(alignment: .leading,
                       spacing: Style.shared.spacing(.medium)) {
                    
                    ForEach(items, id: \.id) {
                        
                        self.section(legalItem: $0)
                        
                    }
                    
                }
                .frame(maxWidth: .infinity)
                .transition(.offset(y: 200).combined(with: .opacity))
                
            }
            
        }
        .frame(maxWidth: .infinity)
        .animation(.spring, value: self.viewModel.legalItems)
        
    }
    
    private func section(legalItem: LegalItem) -> some View {
        
        VStack(alignment: .leading,
               spacing: Style.shared.spacing(.small)) {
            
            Text(legalItem.title)
                .appFont(with: .HEADER_H6)
                .foregroundStyle(Style.shared.textColor(.title).source())
            
            VStack(alignment: .leading, spacing: Style.shared.spacing(.custom(6))) {
                
                ForEach(legalItem.sections, id: \.self) { message in
                    
                    Text(message)
                        .appFont(with: .BODY_B4)
                        .foregroundStyle(Style.shared.textColor(.body).source())
                    
                }
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
        }
        .frame(maxWidth: .infinity)
        
    }
    
}

#Preview {
    
    let viewModel = mockResolve(LegalViewModel.self)
        .setup(context: .termsAndConditions)
    
    return LegalScreen(
        viewModel: viewModel
    )
    .withMockServices()
    
}
