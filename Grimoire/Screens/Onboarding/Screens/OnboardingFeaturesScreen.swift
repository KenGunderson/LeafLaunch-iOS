//
//  OnboardingFeaturesScreen.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 7/2/25.
//

import SwiftUI

struct OnboardingFeaturesScreen: GPView {

    @Environment(\.style) private var style

    @EnvironmentObject private var onboardingViewModel: OnboardingViewModel
    
    @State private var shouldAnimate: Bool = false
    @State private var featureScrollPosition: OnboardingPage.ID?
    
    var body: some View {
        
        VStack(spacing: self.style.spacing(.none)) {

            ScrollView(.horizontal) {

                HStack(spacing: self.style.spacing(.none)) {
                    featureScreens()
                }
                .scrollTargetLayout()

            }
            .scrollPosition(id: self.$featureScrollPosition, anchor: .center)
            .scrollTargetBehavior(.paging)
            .scrollIndicators(.hidden)
            .clipped()
            .onChange(of: self.onboardingViewModel.currentPage) { _, currentPage in
                scrollToFeaturePage(currentPage)
            }
            .onChange(of: self.featureScrollPosition) { _, featureScrollPosition in
                updateCurrentFeaturePage(featureScrollPosition)
            }
            .animation(.smooth(duration: 0.45), value: self.currentFeaturePage.id)

        }
        .frame(maxHeight: .infinity, alignment: .top)
        .onAppear {

            self.featureScrollPosition = self.currentFeaturePage.id

            withAnimation(.smooth(duration: 0.6, extraBounce: 0.2).delay(0.3)) {
                self.shouldAnimate = true
            }

        }
        .onDisappear {

            withAnimation(.smooth(duration: 0.6, extraBounce: 0.2).delay(0.3)) {
                self.shouldAnimate = false
            }

        }
        .opacity(self.shouldAnimate ? 1 : 0)
        .offset(y: self.shouldAnimate ? 0 : 200)
        .padding(.top, OnboardingScreen.headerHeight)

    }

    @ViewBuilder
    private func featureScreens() -> some View {

        ForEach(self.onboardingViewModel.featurePages) { page in

            featurePageContent(page: page)
                .containerRelativeFrame(.horizontal)
                .id(page.id)

        }

    }

    private func featurePageContent(page: OnboardingPage) -> some View {

        VStack(spacing: self.style.spacing(.none)) {

            page
                .illustration
                .view(renderingMode: .original)
                .scaledToFit()
                .frame(height: Constants.Runtime.deviceHeight * 0.53)
                .padding([.top], .large)
                .zIndex(-1)

            VStack(spacing: self.style.spacing(.medium)) {

                Text(page.title)
                    .appFont(with: .HEADER_3)
                    .foregroundStyle(.text(.title))
                    .padding(.horizontal, .large2)

                Text(page.message)
                    .appFont(with: .BODY_4)
                    .foregroundStyle(.text(.body))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, .large2)

            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.top, .large)

        }

    }

    private func scrollToFeaturePage(_ page: OnboardingPage?) {

        guard let page else { return }
        guard self.onboardingViewModel.featurePages.contains(page) else { return }

        withAnimation(.smooth(duration: 0.45)) {
            self.featureScrollPosition = page.id
        }

    }

    private func updateCurrentFeaturePage(_ pageID: OnboardingPage.ID?) {

        guard let pageID else { return }
        guard let page = self.onboardingViewModel.featurePages.first(where: { $0.id == pageID }) else { return }
        guard page != self.onboardingViewModel.currentPage else { return }

        self.onboardingViewModel.updateCurrentFeaturePage(page)

    }

    private var currentFeaturePage: OnboardingPage {

        guard let currentPage = self.onboardingViewModel.currentPage else {
            return .businessSetup
        }

        return self.onboardingViewModel.featurePages.contains(currentPage)
            ? currentPage
            : (self.onboardingViewModel.featurePages.last ?? .businessSetup)

    }
    
}

#Preview {

    let onboardingViewModel = mockResolve(OnboardingViewModel.self)
        .setup(pages: OnboardingPage.allCases)

    OnboardingFeaturesScreen()
        .environmentObject(onboardingViewModel)
}
