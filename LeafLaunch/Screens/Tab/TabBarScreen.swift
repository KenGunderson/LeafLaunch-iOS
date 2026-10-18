//
//  TabBarScreen.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 7/15/24.
//

import SwiftUI

struct TabBarScreen: View {

    @Binding var selectedTab: Tab
    @Binding var isTabBarVisible: Bool

    init(selectedTab: Binding<Tab>,
         isTabBarVisible: Binding<Bool>) {
        self._selectedTab = selectedTab
        self._isTabBarVisible = isTabBarVisible

    }

    var body: some View {

        BubbleTabBarView(selectedTab: self.$selectedTab)
            .offset(y: self.isTabBarVisible ? 0 : 200)
            .animation(.bouncy, value: self.isTabBarVisible)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .ignoresSafeArea(.keyboard)

    }

}

#Preview {

    @Previewable @State var selectedTab: Tab = .tab1
    @Previewable @State var isTabBarVisible: Bool = true

    TabBarScreen(
        selectedTab: $selectedTab,
        isTabBarVisible: $isTabBarVisible
    )
    .withMockPreviews()

}
