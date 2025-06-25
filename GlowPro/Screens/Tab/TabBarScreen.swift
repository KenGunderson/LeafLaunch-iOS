//
//  TabBarScreen.swift
//  GlowPro 
//
//  Created by Sako Hovaguimian on 7/15/24.
//

import SwiftUI

struct TabBarView: View {
    
    enum TabBarStyle<Content: View> {
        case custom(Content) // FloatingTabBar -> FloatingTransitionTabBar
        case standard
    }
    
    @Binding var selectedTab: Tab
    var style: TabBarStyle<AnyView>
    
    var body: some View {
        switch self.style {
        case .custom(let content): content
        case .standard: StandardTabBarView(selectedTab: self.$selectedTab)
        }
    }
    
}

struct TabBarScreen: GPView {

    @Binding var selectedTab: Tab
    @Binding var isTabBarVisible: Bool
    
    private let tab1ViewModel: Tab1ViewModel!
    private let tab2ViewModel: Tab2ViewModel!
    private let tab3ViewModel: Tab3ViewModel!
    private let tab4ViewModel: Tab4ViewModel!
        
    init(selectedTab: Binding<Tab>,
         isTabBarVisibile: Binding<Bool>,
         tab1ViewModel: Tab1ViewModel,
         tab2ViewModel: Tab2ViewModel,
         tab3ViewModel: Tab3ViewModel,
         tab4ViewModel: Tab4ViewModel) {
                
        self._selectedTab = selectedTab
        self._isTabBarVisible = isTabBarVisibile
        
        self.tab1ViewModel = tab1ViewModel
        self.tab2ViewModel = tab2ViewModel
        self.tab3ViewModel = tab3ViewModel
        self.tab4ViewModel = tab4ViewModel
        
    }
    
    var body: some View {
        
        ZStack {
            
            self.backgroundView
            self.tabView
            
            VStack {
                
                Spacer()
                
                TabBarView(
                    selectedTab: self.$selectedTab,
                    style: .standard
                )
                .offset(y: self.isTabBarVisible ? 0 : 200)
                .animation(.spring, value: self.isTabBarVisible)
                
            }
            .ignoresSafeArea(.keyboard)
            
        }
        
    }
    
    private var backgroundView: some View {
     
        Style
            .shared
            .background(.primary)
            .view()
            .ignoresSafeArea()
        
    }
    
    private var tabView: some View {
        
        TabView(selection: self.$selectedTab) {
            
            ForEach(Tab.allCases, id: \.rawValue) { tab in
                
                switch tab {
                case .tab1:
                                        
                    TabBar1Screen(
                        viewModel: self.tab1ViewModel,
                        tab: tab
                    )
                    
                case .tab2:
                    
                    TabBar2Screen(
                        viewModel: self.tab2ViewModel,
                        tab: tab
                    )
                    
                case .tab3:
                    
                    TabBar3Screen(
                        viewModel: self.tab3ViewModel,
                        tab: tab
                    )
                    
                case .tab4:
                    
                    TabBar4Screen(
                        viewModel: self.tab4ViewModel,
                        tab: tab
                    )
                }
                
            }
            
        }
        
    }

}

#Preview {
    
    @Previewable @State var selectedTab: Tab = .tab1
    @Previewable @State var isTabBarVisible: Bool = true
    
    TabBarScreen(
        selectedTab: $selectedTab,
        isTabBarVisibile: $isTabBarVisible,
        tab1ViewModel: mockResolve(Tab1ViewModel.self),
        tab2ViewModel: mockResolve(Tab2ViewModel.self),
        tab3ViewModel: mockResolve(Tab3ViewModel.self),
        tab4ViewModel: mockResolve(Tab4ViewModel.self)
    )
    .withMockServices()
    
}
