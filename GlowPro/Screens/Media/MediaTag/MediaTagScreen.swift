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
        
        // Alerts
        
            .withAlertService(ObservableAlertServiceWrapper(alertService: self.viewModel.alertService))
        
        // Tap
        
            .onTapGesture {
                self.focusedField = nil
            }
        
    }
    
    private func content() -> some View {
        
        AppHeaderScrollView(horizontalPadding: .medium) {
            navBar()
        } scrollViewContent: {
            mediaTagsList()
        }
        .safeAreaInset(edge: .bottom) {
            bottomBarView()
        }
        
    }
    
    private func navBar() -> some View {
        
        let closeButton = NavBarButton(style: .close) {
            
            self.viewModel.updateBusinessDashboardHomeIfNeeded()
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
        
        let sectionTitle = self.viewModel.isMediaSelected
        ? "Select All That Apply"
        : "All Media Tags"
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.small)) {
            
            SectionView(
                leadingTitle: sectionTitle,
                leadingTitleFont: .TITLE_5,
                showDivider: true
            )
            
            VStack {
                
                ForEach(self.viewModel.mediaTags, id: \.self) { tag in
                    
                    mediaTag(tag)
                        .transition(.asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .scale.combined(with: .opacity)
                        ))
                    
                }
                
            }
            
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .top
        )
        .animation(.spring(duration: 0.25), value: self.viewModel.selectedMedia)
        .animation(.spring, value: self.viewModel.mediaTags)
        
    }
    
    @ViewBuilder
    private func mediaTag(_ mediaTag: MediaTag) -> some View {
        
        let isSelected = self.viewModel.selectedMedia?.tags.contains(mediaTag) ?? false
        
        let foregroundStyle = isSelected ? Style.shared.textColor(.button) : Style.shared.textColor(.title)
        let backgroundStyle = isSelected ? Style.shared.accent : Style.shared.background(.secondary)
        
        AppCardView(backgroundStyle: backgroundStyle, cornerRadius: .small, shadow: .subtle) {
            
            HStack(spacing: Style.shared.spacing(.small)) {
                
                Text(mediaTag.name.capitalized)
                    .appFont(with: .TITLE_4)
                    .foregroundStyle(foregroundStyle.source())
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Image(systemName: "trash")
                    .foregroundStyle(foregroundStyle.source())
                    .asButton {
                        
                        self.viewModel
                            .presentMediaTagAlert(mediaTag: mediaTag)
                        
                    }
                
            }
            
        }
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
                .padding(.top, -Style.shared.spacing(.small))
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
        .appShadow(.subtle)
        .allowsHitTesting(self.viewModel.isNewMediaTagValid)
        .opacity(self.viewModel.isNewMediaTagValid ? 1 : 0.75)
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
        .padding(.bottom, .small)
        .appOnTapGesture {
            self.focusedField = fieldToFocus
        }
        
    }
    
    @ViewBuilder
    private func bottomBarView() -> some View {
        
        VStack(spacing: Style.shared.spacing(.small)) {
            
            createTagView()
            
            if self.focusedField == nil {
                
                CommonButton(title: "Done") {
                    
                    self.viewModel.updateBusinessDashboardHomeIfNeeded()
                    dismiss()
                    
                }
                
            } else {
                
                EmptyView()
                    .frame(height: 16)
                
            }
            
        }
        .padding(.top, .medium)
        .padding(.horizontal, .medium)
        .background(Style.shared.background(.primary).source())
        .animation(.bouncy(duration: 0.1), value: self.focusedField)
        
    }
    
}

#Preview {
    
    let viewModel = mockResolve(MediaTagViewModel.self)
        .setup(media: MockModels.MockMedia.media1)
    
    MediaTagScreen(viewModel: viewModel)
        .withMockServices()
    
}
