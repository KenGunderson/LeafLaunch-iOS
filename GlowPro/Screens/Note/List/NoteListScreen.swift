//
//  NoteListScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 9/13/25.
//

import SwiftUI

struct NoteListScreen: GPView {
    
    @Environment(NavigationService.self) private var navigationService
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var viewModel: NoteListViewModel
    
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
        
        AppHeaderScrollView(horizontalPadding: .none) {
            navBar()
        } scrollViewContent: {
            contentCards()
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
                .push(.note(.noteCreateEdit(
                    context: .create,
                    clientId: self.viewModel.clientId)
                ))
            
        }
        .asAnyView()
        
        return NavBarView(
            title: "Locations",
            leftButtonView: backButton,
            rightButtonView: plusButton
        )
        
    }
    
    
    private func contentCards() -> some View {
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.medium)) {
            
            ForEach(self.viewModel.notes, id: \.id) { note in
                noteItem(note)
            }
            
        }
        .padding(.horizontal, .medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
    private func noteItem(_ note: Note) -> some View {
        
        AppCardView {
            
            VStack(alignment: .leading, spacing: Style.shared.spacing(.small2)) {
                
                HStack {
                    
                    Text(note.title)
                        .appFont(with: .TITLE_5)
                        .foregroundStyle(Style.shared.textColor(.title).source())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                }
                
            }
            .asButton {
                
                self.navigationService
                    .push(.note(.noteCreateEdit(
                        context: .update(noteId: note.id),
                        clientId: note.clientId.id)
                    ))
                
            }
            
        }
        
    }

}

#Preview {
    
    let viewModel = mockResolve(NoteListViewModel.self)
        .setup(clientId: MockModels.ID.client1)
    
    NoteListScreen(viewModel: viewModel)
        .withMockServices()
    
}
