//
//  FeatureRequestScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 9/12/25.
//

import SwiftUI

struct FeatureRequestScreen: GPView {
    
    @StateObject var viewModel: FeatureRequestViewModel
    @Environment(NavigationService.self) private var navigationService
    
    @State private var onAppearAnimation: Bool = false
    @State private var showBottomBar: Bool = false
    
    @FocusState private var isFocused: Bool
            
    var body: some View {
        
        AppHeaderScrollView(horizontalPadding: .medium) {
            headerView()
        } scrollViewContent: {
            content()
        }
        .safeAreaInset(edge: .bottom) {
            bottomBar()
        }
        
        // Lifecycle
        
        .onFirstAppear {
            
            self.viewModel
                .track()
            
            self.viewModel
                .setup(navigationService: self.navigationService)
            
        }
        .task {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                
                self.onAppearAnimation = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.showBottomBar = true
                }
                
            }
            
        }
        
        // Animation
        
        .animation(.snappy(duration: 0.5), value: self.onAppearAnimation)
        .animation(.snappy(duration: 0.3).delay(0.3), value: self.showBottomBar)
        
        // Tap
        
        .onTapGesture {
            self.isFocused = false
        }

    }
    
    @ViewBuilder
    private func headerView() -> some View {
        
        NavBarView(
            title: "Feature Request",
            leftButtonView: (
                NavBarButton(style: .back) {
                    self.viewModel.dismiss()
                }
            ).asAnyView()
        )
        
    }
    
    @ViewBuilder
    private func content() -> some View {
        
        let config = Constants.StaggerAnimation.config(interitemSpacing: Style.shared.spacing(.small2))
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.small)) {
            
            StaggeredView(config: config) {
                
                if self.onAppearAnimation {
                    
                    Text("Your feedback and suggestions are very valuable to us. Please share what you would like to see added to GlowPro.")
                        .appFont(with: .BODY_4)
                        .foregroundStyle(Style.shared.textColor(.body).source())
                        .multilineTextAlignment(.leading)
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                    
                    CommonTextEditView(
                        text: self.$viewModel.featureRequestText,
                        placehoderText: "...",
                        isFocused: self.isFocused,
                        shadow: .none,
                        lineLimit: 10...10
                    )
                    .focused(self.$isFocused)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    
                }
                
            }
            
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        
    }
    
    @ViewBuilder
    private func bottomBar() -> some View {
        
        if self.showBottomBar {
            
            CommonButton(title: "Submit") {
                
                self.viewModel
                    .submit()
                
            }
            .padding(.horizontal, .medium)
            .opacity(self.isFocused ? 0 : 1)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            
        }
        
    }
    
}

#Preview {
    
    FeatureRequestScreen(
        viewModel: mockResolve(FeatureRequestViewModel.self)
    )
    .withMockServices()
    
}
