//
//  OnboardingScreen.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 7/18/24.
//

import SwiftUI
import Foundation

struct OnboardingScreen: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel: OnboardingViewModel
    
    @State private var navigationService = NavigationService()
    @State private var headerSize: CGSize = .zero
    
    static let headerHeight = 46.6
    
    init(viewModel: OnboardingViewModel) {
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            AppRootView(
                navigationService: self.$navigationService,
                alertService: self.viewModel.alertService
            ) {
                OnboardingWelcomeScreen()
            }
            
            headerView()
            
        }
        .safeAreaInset(edge: .bottom) {
            
            self.bottomButtonView
                .padding(.horizontal, .medium)
            
        }
        .onFirstAppear {
            
            self.viewModel
                .track()
            
            self.viewModel
                .setup(navigationService: self.navigationService)
            
        }
        .onChange(of: self.navigationService.routes) { oldValue, newValue in
            
            guard !oldValue.isEmpty else { return }
            self.viewModel.findNavigationRouteIndex(routes: newValue)
            
        }
        .animation(.smooth(duration: 0.6), value: self.viewModel.currentPage)
        .animation(.smooth(duration: 0.6), value: self.viewModel.currentPageIndex)
        
    }
    
    private func headerView() -> some View {
        
        HStack(spacing: Style.shared.spacing(.medium)) {
            
            Text("Back")
                .appFont(with: .TITLE_3)
                .foregroundStyle(Style.shared.accent.source())
                .frame(height: self.headerSize.height)
                .disabled(self.navigationService.routes.isEmpty)
                .opacity(self.navigationService.routes.isEmpty ? 0.6 : 1)
                .allowsHitTesting(!self.navigationService.routes.isEmpty)
                .asButton {
                    self.navigationService.routes.removeLast()
                }
            
            ProgressView(
                value: self.viewModel.progress,
                label: { Text("") },
                currentValueLabel: { Text(self.viewModel.formattedProgressPercentage) }
            )
            .tint(Style.shared.accent.source())
            .contentTransition(.numericText())
            
            let isButtonEnabled = self.viewModel.isLastPage ? self.viewModel.didAcknowledgePermissions : true
            
            Text("Next")
                .appFont(with: .TITLE_3)
                .foregroundStyle(Style.shared.accent.source())
                .frame(height: self.headerSize.height)
                .disabled(!isButtonEnabled)
                .opacity(isButtonEnabled ? 1 : 0.6)
                .allowsHitTesting(isButtonEnabled)
                .asButton {
                    
                    if self.viewModel.isLastPage {
                        
                        self.viewModel.finish()
                        dismiss()
                        
                    } else {
                        self.viewModel.nextPage()
                    }
                    
                }
            
        }
        .padding(.horizontal, .medium)
        .animation(.easeInOut, value: self.viewModel.progress)
        .background(.clear)
        .onGeometryChange(for: CGSize.self) { geo in
            return geo.size
        } action: { headerSize in
            self.headerSize = headerSize
        }
        
    }
    
    private var bottomButtonView: some View {

        let isButtonEnabled = self.viewModel.isLastPage ? self.viewModel.didAcknowledgePermissions : true
        
        return HStack(spacing: Style.shared.spacing(.small)) {
            
            CommonButton(title: self.viewModel.isLastPage ? "Finish" : "Next", isEnabled: isButtonEnabled) {
                
                if self.viewModel.isLastPage {
                    
                    self.viewModel.finish()
                    dismiss()
                    
                } else {
                    self.viewModel.nextPage()
                }
                
            }
            .contentTransition(.numericText())
            .transition(.move(edge: .trailing).combined(with: .opacity))
            
        }
        .foregroundStyle(.black)
        .animation(.smooth(duration: 0.6), value: self.viewModel.currentPageIndex)
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .preferredColorScheme(.light)
        
    }
    
}

#Preview {
    
    OnboardingScreen(
        viewModel: mockResolve(OnboardingViewModel.self)
            .setup(pages: [
                .welcome,
                .captureProgress,
                .compareResults,
                .shareGrow,
                .permission
            ])
    )
    .withMockServices()
    
}
