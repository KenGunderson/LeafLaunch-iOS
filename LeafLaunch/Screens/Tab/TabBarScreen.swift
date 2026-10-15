//
//  TabBarScreen.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 7/15/24.
//

import SwiftUI

struct TabBarScreen: View {

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @Binding var selectedTab: Tab
    @Binding var isTabBarVisible: Bool

    init(selectedTab: Binding<Tab>,
         isTabBarVisible: Binding<Bool>) {
        self._selectedTab = selectedTab
        self._isTabBarVisible = isTabBarVisible

    }

    var body: some View {

        VStack {

            Spacer()

            BubbleTabBarView(selectedTab: self.$selectedTab)
                .offset(y: self.isTabBarVisible ? 0 : 200)
                .animation(self.reduceMotion ? nil : .bouncy, value: self.isTabBarVisible)

        }
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
