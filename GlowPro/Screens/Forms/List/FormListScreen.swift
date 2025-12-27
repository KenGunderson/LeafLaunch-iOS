//
//  FormListScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 11/6/25.
//

import SwiftUI

struct FormListScreen: GPView {
    
    @StateObject var viewModel: FormListViewModel
    @Environment(NavigationService.self) private var navigationService
    
    @State private var showAddFileSheet: Bool = false
    
    var itemsPerRow: Int {
        return ProcessInfo.processInfo.isIpad ? 5 : 2
    }
            
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
        
        // Animations
        
            .animation(.smooth, value: self.viewModel.forms)
        
        // Sheet
        
            .fileImporter(isPresented: self.$showAddFileSheet,
                          allowedContentTypes: [.pdf],
                          allowsMultipleSelection: false) { result in
                
                self.viewModel
                    .handleUploadURLResult(result)
                
            }
        
    }
    
    private func content() -> some View {
        
        AppHeaderScrollView(backgroundStyle: Style.shared.background(.primary)) {
            navBar()
        } scrollViewContent: {
            formList()
        }

    }
    
    private func navBar() -> some View {
        
        let backButton = NavBarButton(style: .back) {
            self.viewModel.dismiss()
        }
        .asAnyView()
        
        let plusButton = NavBarButton(style: .plus) {
            self.showAddFileSheet = true
        }
        .asAnyView()
        
        return NavBarView(
            title: "Forms",
            leftButtonView: backButton,
            rightButtonView: self.viewModel.shouldShowAddButton ? plusButton : nil
        )
        
    }
    
    @ViewBuilder
    private func formList() -> some View {
        
        let glowProForms = GlowProForm.allCases.map({ Form(
            id: $0.id,
            locationId: "",
            title: $0.displayName,
            mediaURL: $0.url
        )})
        
        VStack(spacing: Style.shared.spacing(.medium)) {
            
            list(
                title: "Your Uploaded Forms",
                forms: self.viewModel.forms
            )
            
            list(
                title: "GlowPro Forms",
                forms: glowProForms
            )
            
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, .custom(86))
        .compositingGroup()
        .geometryGroup()
        
    }
    
    @ViewBuilder
    private func list(title: String,
                      forms: [Form]) -> some View {
        
        if !forms.isEmpty {
            
            VStack(spacing: Style.shared.spacing(.small2)) {
                
                SectionView(
                    leadingTitle: title,
                    showDivider: true
                )
                
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: self.itemsPerRow),
                    spacing: 8
                ) {
                    
                    ForEach(forms, id: \.id) { form in
                        formItem(form)
                    }
                    
                }
                
            }
            .compositingGroup()
            .geometryGroup()
            .transition(.move(edge: .bottom).combined(with: .opacity))
            
        }
        
    }
    
    private func formItem(_ form: Form) -> some View {
        
        let width = (UIScreen.main.bounds.width - 32 - 32) / CGFloat(self.itemsPerRow)
        
        let shouldShowContextMenu: Bool = (
            !form.locationId.isEmpty &&
            self.viewModel.mode == .preview &&
            self.viewModel.isOwnerOrManager
        )
        
        return VStack {
            
            DownsampledRemoteImage(
                url: form.mediaURL,
                targetSize: .init(width: width, height: width),
                contentMode: .fill,
                placeholder: PlaceholderView().asAnyView()
            )
            .frame(
                width: width,
                height: width + (width * 0.40)
            )
            .clipped()
            .contentShape(.rect)
            .clipShape(.rect)
            .cornerRadius(.small)
            .appShadow(.card)
            .asButton {
                
                self.viewModel
                    .selectForm(form)
                
            }
            .overlay(alignment: .topTrailing) {
                
                if shouldShowContextMenu {
                    
                    contextMenu(form: form)
                        .preferredColorScheme(.light)
                    
                }
                
            }
            
            Text(form.title)
                .appFont(with: .TITLE_4)
                .foregroundStyle(Style.shared.textColor(.title).source())
                .minimumScaleFactor(0.6)
                .lineLimit(1)
            
        }
        .compositingGroup()
        .geometryGroup()
        
    }
    
    private func contextMenu(form: Form) -> some View {
        
        Menu {
            
            Button("Edit") {
                
                self.navigationService
                    .push(.form(.formCreateEdit(
                        formId: form.id,
                        mediaURL: form.mediaURL
                    )))
                
            }
            
        } label: {
            
            CircularIconView(
                foregroundColor: .color(.black),
                backgroundColor: Style.shared.background(.quaternary),
                imageSource: .systemImage("ellipsis"),
                size: 32
            )
            .padding([.trailing, .top], .small)
            .asButton {
                
                self.navigationService
                    .push(.form(.formCreateEdit(
                        formId: form.id,
                        mediaURL: form.mediaURL
                    )))
                
            }
            
        }
        
    }
    
}

#Preview {
    
    let viewModel = mockResolve(FormListViewModel.self)
        .setup(
            context: .location(locationId: MockModels.ID.location1),
            mode: .preview
        )
    
    FormListScreen(
        viewModel: viewModel
    )
    .withMockServices()
    
}
