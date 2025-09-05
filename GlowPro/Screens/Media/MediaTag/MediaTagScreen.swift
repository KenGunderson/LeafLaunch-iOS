//
//  MediaTagScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 9/3/25.
//

import SwiftUI

struct MediaTagScreen: GPView {
    
    enum FocusedField: Hashable {
        case newTag
    }
    
    @Environment(NavigationService.self) private var navigationService
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var viewModel: MediaTagViewModel
    
    @FocusState private var focusedField: FocusedField?
    
    var body: some View {
        
        content()
        
        // Lifecycle
        
            .onFirstAppear {
                
                self.viewModel
                    .track()
                
                self.viewModel
                    .setup(navigationService: self.navigationService)
                
            }
            
        // Task
        
            .task {
                
                self.viewModel
                    .loadData()
                
            }
        
        // Tap
        
            .onTapGesture {
                self.focusedField = nil
            }
        
    }
    
    private func content() -> some View {
        
        AppBaseView {
            mediaTagsList()
        }
        .safeAreaInset(edge: .top) {
            navBar()
        }
        .safeAreaInset(edge: .bottom) {
            bottomBarView()
        }
        
    }
    
    private func navBar() -> some View {
        
        let closeButton = NavBarButton(style: .close) {
            self.dismiss()
        }
        .asAnyView()
        
        return NavBarView(
            title: "Media Tags",
            rightButtonView: closeButton
        )
        
    }
    
    @ViewBuilder
    private func mediaTagsList() -> some View {
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.medium2)) {
            
            SectionView(
                leadingTitle: "Your Tags",
                showDivider: true
            )
            
            WStack {
                
                ForEach(self.viewModel.mediaTags, id: \.self) { tag in
                    
                    mediaTag(tag)
                        .transition(.scale.combined(with: .opacity))
                    
                }
                
            }
            
            createTagView()
            
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .top
        )
        .animation(.spring, value: self.viewModel.selectedMedia)
        .animation(.spring, value: self.viewModel.mediaTags)
        .padding(.horizontal, .medium)
        .padding(.top, .medium)
        
    }
    
    private func mediaTag(_ mediaTag: MediaTag) -> some View {
        
        let isSelected = self.viewModel.selectedMedia.tags.contains(mediaTag)
        
        return TokenView(
            text: mediaTag.name,
            foregroundStyle: isSelected ? Style.shared.textColor(.button) : Style.shared.textColor(.title),
            backgroundStyle: isSelected ? Style.shared.accent : .color(.clear),
            verticalPadding: .extraSmall,
            clipShape: .init(.rect(cornerRadius: Style.shared.radius(.extraSmall)))
        )
        .appBorder(
            cornerRadius: .extraSmall,
            color: isSelected ? Style.shared.accent : Style.shared.background(.border),
            lineWidth: 1.5
        )
        .appShadow(.subtle)
        .asButton {
            
            self.viewModel
                .addOrDeleteMediaTagForMedia(mediaTag)
            
        }
        
    }
    
    @ViewBuilder
    private func createTagView() -> some View {
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.small)) {
            
            Text("Can't find a tag? Add it yourself.")
                .appFont(with: .TITLE_5)
                .foregroundStyle(Style.shared.textColor(.title).source())
            
            textField(fieldToFocus: .newTag)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(1)
                .padding(.top, -Style.shared.spacing(.large))
            
            if !self.viewModel.newMediaTag.isEmpty {
                
                HStack {
                    
                    Spacer()
                    createTagButton()
                    
                }
                .zIndex(-1)
                .transition(.move(edge: .top).combined(with: .opacity))
                
            }
            
        }
        .animation(.snappy, value: self.viewModel.newMediaTag)
        
    }
    
    @ViewBuilder
    private func createTagButton() -> some View {
        
        TokenView(
            text: "Create Tag",
            foregroundStyle: Style.shared.textColor(.button),
            backgroundStyle: Style.shared.accent,
            verticalPadding: .small,
            clipShape: .init(.rect(cornerRadius: Style.shared.radius(.extraSmall)))
        )
        .appBorder(
            cornerRadius: .extraSmall,
            color: Style.shared.accent,
            lineWidth: 1.5
        )
        .appShadow(.subtle)
        .asButton {
            
            viewModel
                .createMediaTag()
            
        }
        
    }
    
    @ViewBuilder
    private func textField(fieldToFocus: FocusedField) -> some View {
        
        let placeholder = "New Tag..."
        let text = self.$viewModel.newMediaTag
        let isFocused = self.focusedField == fieldToFocus
        
        TextField(
            "placeholder",
            text: text,
            prompt: Text(placeholder).foregroundStyle(Style.shared.textColor(.placeholder).source())
        )
        .titleUnderlineTextFieldStyle(
            text: text.wrappedValue,
            title: "",
            style: .border(cornerRadius: .custom(6)),
            isFocused: isFocused,
            textFieldFont: .BODY_3,
            titleFont: .BODY_2
        )
        .focused(self.$focusedField, equals: fieldToFocus)
        .keyboardType(.default)
        .submitLabel(.done)
        .textInputAutocapitalization(.words)
        .appOnTapGesture {
            self.focusedField = fieldToFocus
        }
        
    }
    
    @ViewBuilder
    private func bottomBarView() -> some View {
        
        CommonButton(title: "Done") {
            dismiss()
        }
        .padding(.horizontal, .medium)
        .opacity(self.focusedField == nil ? 1 : 0)
        .animation(.bouncy(duration: 0.1), value: self.focusedField)
        
    }
    
}

#Preview {
    
    let viewModel = mockResolve(MediaTagViewModel.self)
        .setup(media: MockModels.MockMedia.media1)
    
    MediaTagScreen(viewModel: viewModel)
        .withMockServices()
    
}
