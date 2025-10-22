//
//  CollageListScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 10/18/25.
//

import SwiftUI

struct CollageListScreen: GPView {
    
    @Environment(NavigationService.self) private var navigationService
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var viewModel: CollageListViewModel
    
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
        
        // Animation
        
            .animation(.snappy, value: self.viewModel.groupedCollages)
            .animation(.snappy, value: self.viewModel.shouldShowEmptyState)
        
    }
    
    private func content() -> some View {
        
        AppHeaderScrollView(horizontalPadding: .none) {
            navBar()
        } scrollViewContent: {
            collageList()
        }
        .emptyStateOverlay(
            shouldShow: self.viewModel.shouldShowEmptyState,
            config: self.viewModel.emptyStateConfig()
        )
        
    }
    
    private func navBar() -> some View {
        
        let backButton = NavBarButton(style: .back) {
            self.dismiss()
        }
        .asAnyView()
        
        let plusButton = NavBarButton(style: .plus) {
                        
            self.navigationService
                .push(.collage(.createEdit(
                    clientId: self.viewModel.clientId,
                    collageId: nil
                )))
            
        }
        .asAnyView()
        
        return NavBarView(
            title: "Collages",
            leftButtonView: backButton,
            rightButtonView: self.viewModel.allowsCollageCreation ? plusButton : nil
        )
        
    }
    
    @ViewBuilder
    private func collageList() -> some View {
        
        VStack(spacing: Style.shared.spacing(.large)) {
            
            ForEach(self.viewModel.groupedCollages, id: \.id) { group in
                
                groupSection(group)
                    .transition(.offset(y: 300).combined(with: .opacity))
                
            }
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
    private func groupSection(_ groupedMedia: CollageListViewModel.GroupedCollages) -> some View {
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.small2)) {
            
            sectionHeader(groupedMedia)
            
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2),
                spacing: 4
            ) {
                
                ForEach(groupedMedia.collages.indices, id: \.id) { index in
                    collageItem(groupedMedia.collages[index])
                }
                
            }
            
        }
        .padding(.horizontal, .medium)
        .compositingGroup()
        .geometryGroup()
        
    }
        
    private func sectionHeader(_ groupedMedia: CollageListViewModel.GroupedCollages) -> some View {
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.extraSmall)) {
            
            HStack {
                
                Text(groupedMedia.title)
                    .appFont(with: .HEADER_2)
                    .foregroundStyle(Style.shared.textColor(.title).source())
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                let plural = groupedMedia.collages.count == 1 ? "" : "s"
                Text("\(groupedMedia.collages.count) collage\(plural)")
                    .appFont(with: .BODY_1)
                    .foregroundStyle(Style.shared.textColor(.title).source())
                
            }
            
            Divider()
                .foregroundStyle(Style.shared.background(.quaternary).source())
            
        }
        
    }
    
    private func collageItem(_ collage: Collage) -> some View {
        
        CollageView(
            items: collage.mediaURLs,
            type: collage.type,
            height: UIScreen.main.bounds.width / 2 - (Style.shared.spacing(.medium) * 2)
        )
        
    }

}

#Preview {
    
    let viewModel = mockResolve(CollageListViewModel.self)
        .setup(context: .client(clientId: MockModels.ID.client1))
    
    CollageListScreen(viewModel: viewModel)
        .withMockServices()
    
}
