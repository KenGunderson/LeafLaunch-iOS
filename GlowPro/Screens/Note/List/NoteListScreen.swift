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
            noteList()
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
            title: "Notes",
            leftButtonView: backButton,
            rightButtonView: plusButton
        )
        
    }
    
    
    private func noteList() -> some View {
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.medium)) {
            
            ForEach(self.viewModel.notes, id: \.id) { note in
                noteItem(note)
            }
            
        }
        .padding(.horizontal, .medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
    private func noteItem(_ note: Note) -> some View {
        
        AppCardView(shadow: .subtle) {
            
            VStack(alignment: .leading, spacing: Style.shared.spacing(.small2)) {
                
                Text(note.title)
                    .appFont(with: .TITLE_3)
                    .foregroundStyle(Style.shared.textColor(.title).source())
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(note.message)
                    .appFont(with: .BODY_2)
                    .lineLimit(2)
                    .foregroundStyle(Style.shared.textColor(.title).source())
                    .frame(maxWidth: .infinity, alignment: .leading)
                
            }
            
            VStack {
                
                Text(note.createdAt?.relativeDateString() ?? "")
                    .appFont(with: .BODY_2)
                    .foregroundStyle(Style.shared.textColor(.body).source())
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 12, height: 12)
                    .foregroundStyle(Style.shared.textColor(.body).source())
                
                Spacer()
                
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

#Preview {
    
    let viewModel = mockResolve(NoteListViewModel.self)
        .setup(clientId: MockModels.ID.client1)
    
    NoteListScreen(viewModel: viewModel)
        .withMockServices()
    
}
