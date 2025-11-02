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
                    .loadData(offset: 0)
                
            }
        
        // Sheets
        
            .adaptiveSheet(
                isPresented: self.$viewModel.shouldShowNoteTypeSelectionView,
                additionalDetens: [],
                backgroundStyle: Style.shared.background(.primary)
            ) {
                
                NoteTypeSelectionView { type in
                    
                    self.navigationService
                        .push(.note(.noteCreateEdit(
                            context: .create(),
                            noteType: type,
                            clientId: self.viewModel.clientId)
                        ))
                    
                }
                
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
            config: self.viewModel.emptyStateConfig(),
            transition: .move(edge: .bottom).combined(with: .opacity),
            animation: .spring
        )
        
    }
    
    private func navBar() -> some View {
        
        let backButton = NavBarButton(style: .back) {
            self.dismiss()
        }
        .asAnyView()
        
        let plusButton = NavBarButton(style: .plus) {
            
            self.viewModel
                .set(shouldShowNoteTypeSelectionView: true)
            
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
            
            filtersView()
            
            if !self.viewModel.notes.isEmpty {
                
                ForEach(self.viewModel.notes, id: \.id) { note in
                    noteItem(note)
                }
                .transition(.offset(y: 400).combined(with: .opacity))
                .padding(.horizontal, .medium)
                
            }
            
        }
        .animation(.bouncy, value: self.viewModel.notes)
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
    private func filtersView() -> some View {
        
        ScrollView(.horizontal) {
            
            HStack {
                
                ForEach(NoteType.allCases, id: \.rawValue) { noteType in
                    filterView(noteType)
                }
                
            }
            
        }
        .safeAreaPadding(.horizontal, Style.shared.spacing(.medium))
        
    }
    
    private func filterView(_ noteType: NoteType) -> some View {
        
        let isSelected = self.viewModel.selectedNoteType == noteType
        let selectedBackgroundColor = noteType.backgroundColor
        let opacityBackgroundColor: ColorSource = .color(selectedBackgroundColor.asColor!.opacity(0.15))
        
        return TokenView(
            text: noteType.displayName,
            foregroundStyle: isSelected ? selectedBackgroundColor : Style.shared.textColor(.title),
            backgroundStyle: isSelected ? opacityBackgroundColor : .color(.clear),
            verticalPadding: .small,
            clipShape: .init(.rect(cornerRadius: Style.shared.radius(.extraSmall)))
        )
        .appBorder(
            cornerRadius: .extraSmall,
            color: isSelected ? selectedBackgroundColor : Style.shared.background(.border),
            lineWidth: 1.5
        )
        .appShadow(.subtle)
        .appOnTapGesture {
            
            self.viewModel
                .set(noteTypeFilter: noteType)
            
        }
        
    }
    
    private func noteItem(_ note: Note) -> some View {
        
        AppCardView(shadow: .subtle) {
            
            HStack(spacing: Style.shared.spacing(.small)) {
                
                VStack(alignment: .leading, spacing: Style.shared.spacing(.custom(0))) {
                    
                    HStack {
                        
                        Text(note.title)
                            .appFont(with: .TITLE_5)
                            .foregroundStyle(Style.shared.textColor(.title).source())
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Menu {
                            
                            Button("Duplicate") {
                                
                                self.navigationService
                                    .push(.note(.noteCreateEdit(
                                        context: .create(noteId: note.id),
                                        noteType: note.type,
                                        clientId: self.viewModel.clientId)
                                    ))
                                
                            }
                            
                        } label: {
                            
                            Image(systemName: "ellipsis")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 16, height: 16)
                                .foregroundStyle(Style.shared.textColor(.body).source())
                                .padding(8)
                                .background(.backgroundTappable)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            
                        }
                        
                    }
                    
                    if !note.message.isEmpty {
                        
                        Text(note.message)
                            .appFont(with: .BODY_2)
                            .lineLimit(2)
                            .foregroundStyle(Style.shared.textColor(.title).source())
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                    }
                    
                    statItems(note: note)
                        .padding(.top, .custom(6))
                    
                }
                
            }
            
        }
        .onAppear {
         
            if note.id == self.viewModel.notes.last?.id {
                
                self.viewModel.loadData(
                    offset: self.viewModel.notes.count
                )
                
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
    
    @ViewBuilder
    private func statItems(note: Note) -> some View {
        
        HStack {
            
            TokenView(
                text: note.type.displayName,
                foregroundStyle: note.type.backgroundColor,
                backgroundStyle: .color(note.type.backgroundColor.asColor!.opacity(0.15))
            )
            .appBorder(
                cornerRadius: .extraLarge,
                color: note.type.backgroundColor,
                lineWidth: 1.5
            )
            
            Spacer()
            
            if !note.mediaURLs.isEmpty {
                
                statItem(
                    icon: "paperclip",
                    value: "\(note.mediaURLs.count)"
                )
                
            }
            
            statItem(
                icon: "clock",
                value: note.createdAt?.relativeDateStringWithOverride() ?? ""
            )
                        
        }
        
    }
    
    private func statItem(icon: String,
                          value: String) -> some View {
        
        HStack(spacing: Style.shared.spacing(.extraSmall)) {
            
            Image(systemName: icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 12, height: 12)
                .foregroundStyle(Style.shared.textColor(.body).source())
            
            Text(value)
                .appFont(with: .BODY_3)
                .foregroundStyle(Style.shared.textColor(.body).source())
            
        }
        
    }

}

#Preview {
    
    let viewModel = mockResolve(NoteListViewModel.self)
        .setup(clientId: MockModels.ID.client1)
    
    NoteListScreen(viewModel: viewModel)
        .withMockServices()
    
}
