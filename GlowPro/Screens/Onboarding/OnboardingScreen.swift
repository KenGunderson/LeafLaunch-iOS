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
    @State private var headerSize: CGSize = .zero
    
    init(viewModel: OnboardingViewModel) {
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
        
        AppBaseView(
            alignment: .top,
            horizontalPadding: .none
        ) {
            
            ZStack(alignment: .top) {
                
                Color.clear
                    .ignoresSafeArea()
                
                headerView()
                tabView()
                
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaInset(edge: .bottom) {
            
            self.bottomButtonView
                .padding(.horizontal, .large)
            
        }
        .onFirstAppear {
            
            self.viewModel
                .track()
            
        }
        
    }
    
    @ViewBuilder
    private func pageView(for page: OnboardingPage) -> some View {
        
        switch page {
        case .welcome:
            
            OnboardingWelcomePage(
                onAppear: { self.viewModel.onPageAppear(page) },
                onDisappear: { self.viewModel.onPageDisappear(page)}
            )
            
        case .features:
            
            OnboardingFeaturesPage(
                onAppear: { self.viewModel.onPageAppear(page) },
                onDisappear: { self.viewModel.onPageDisappear(page)}
            )
            
        case .permission:
            
            OnboardingPermissionsPage(
                permissionService: self.viewModel.permissionService,
                onAppear: { self.viewModel.onPageAppear(page) },
                onDisappear: { self.viewModel.onPageDisappear(page)}
            )
        }

    }
    
    private func headerView() -> some View {
     
        ProgressView(
            value: self.viewModel.progress,
            label: { Text(self.viewModel.formattedProgress) },
            currentValueLabel: { Text(self.viewModel.formattedProgressPercentage) }
        )
        .tint(Style.shared.accent.source())
        .contentTransition(.numericText())
        .padding(.horizontal, .large)
        .animation(.easeInOut, value: self.viewModel.progress)
        .background(.clear)
        .onGeometryChange(for: CGSize.self) { geo in
            return geo.size
        } action: { headerSize in
            self.headerSize = headerSize
        }
        
    }
    
    private func tabView() -> some View {
        
        TabView(selection: self.$viewModel.currentPageIndex) {
            
            ForEach(Array(self.viewModel.pages.enumerated()), id: \.element) { index, page in
                
                self.pageView(for: page)
                    .id(index)
                    .tag(index)
                    .simultaneousGesture(DragGesture(minimumDistance: 0))
                
            }
            
        }
        .padding(.top, self.headerSize.height + 16)
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(.smooth(duration: 0.6), value: self.viewModel.currentPage)
        .animation(.smooth(duration: 0.6), value: self.viewModel.currentPageIndex)
        
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
                .features,
                .permission
            ])
    )
    .withMockServices()
    
}
