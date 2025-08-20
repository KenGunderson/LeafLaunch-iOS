//
//  MediaGalleryScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/20/25.
//

import SwiftUI

struct MediaGalleryScreen: GPView {
    
    @Environment(NavigationService.self) private var navigationService
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var viewModel: MediaGalleryViewModel
        
    var body: some View {
        
        AppHeaderScrollView(horizontalPadding: .none) {
            navBar()
        } scrollViewContent: {
            content()
        }
        
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
    
    private func navBar() -> some View {
        
        let backButton = NavBarButton(style: .back) {
            self.dismiss()
        }
        .asAnyView()
        
        return NavBarView(
            title: "Photo Gallery",
            leftButtonView: backButton
        )
        
    }
    
    @ViewBuilder
    private func content() -> some View {
        
        LazyVStack(spacing: Style.shared.spacing(.large)) {
            
            ForEach(self.viewModel.groups, id: \.id) { group in
                groupSection(group)
            }
            
        }
        .padding(.horizontal, .medium)
        
    }
    
    private func groupSection(_ groupedMedia: MediaGalleryViewModel.GroupedMedia) -> some View {
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.small2)) {
            
            VStack(alignment: .leading, spacing: Style.shared.spacing(.extraSmall)) {
                
                HStack {
                    
                    Text(groupedMedia.title)
                        .appFont(with: .HEADER_2)
                        .foregroundStyle(Style.shared.textColor(.title).source())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    let plural = groupedMedia.media.count == 1 ? "" : "s"
                    Text("\(groupedMedia.media.count) photo\(plural)")
                        .appFont(with: .BODY_1)
                        .foregroundStyle(Style.shared.textColor(.title).source())
                    
                }
                
                Divider()
                    .foregroundStyle(Style.shared.background(.quaternary).source())
                
            }
            
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 5),
                spacing: 4
            ) {
                
                let placeholderView = AppLoadingView(style: .circleRunner(
                    color: Style.shared.background(.quaternary),
                    size: 16
                ))
                .asAnyView()
                
                ForEach(groupedMedia.media) { item in
                    
                    ImageSource.remote(
                        url: item.url,
                        placeholder: placeholderView,
                    )
                    .view(shouldResize: false)
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(.small)
                    
                }
                
            }
            
        }
        
    }
    
}

#Preview {
    
    let viewModel = mockResolve(MediaGalleryViewModel.self)
        .setup(context: .business(businessId: MockModels.ID.business1))
    
    MediaGalleryScreen(viewModel: viewModel)
        .withMockServices()
    
}
