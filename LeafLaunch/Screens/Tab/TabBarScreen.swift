//
//  TabBarScreen.swift
//  LeafLaunch
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

struct TabBarScreen: View {

    @Binding var selectedTab: Tab
    @Binding var isTabBarVisible: Bool
    
    init(selectedTab: Binding<Tab>,
         isTabBarVisibile: Binding<Bool>) {
        self._selectedTab = selectedTab
        self._isTabBarVisible = isTabBarVisibile

    }
    
    var body: some View {
        
        ZStack {
            
            self.backgroundView
            
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
    
}

#Preview {
    
    @Previewable @State var selectedTab: Tab = .tab1
    @Previewable @State var isTabBarVisible: Bool = true
    
    TabBarScreen(
        selectedTab: $selectedTab,
        isTabBarVisibile: $isTabBarVisible
    )
    .withMockServices()
    
}
