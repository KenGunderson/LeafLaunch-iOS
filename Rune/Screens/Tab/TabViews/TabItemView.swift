//
//  TabBarItem.swift
//  SwiftUIDemo
//
//  Created by Sako Hovaguimian on 4/17/24.
//

import SwiftUI

struct TabItemView: View {
    
    var tab: Tab
    @Binding var selectedTab: Tab
    
    let accentColor = Style.shared.accent
    
    var body: some View {
        
        let isSelectedTab = self.tab == self.selectedTab
        let foregroundColor: ColorSource = isSelectedTab ? self.accentColor : .color(.gray)
        
        VStack(spacing: 4) {
            
            Image(systemName: isSelectedTab ? self.tab.selectedIcon : self.tab.unselectedIcon)
                .frame(maxWidth: 24, maxHeight: 24)
                .scaleEffect(isSelectedTab ? 1.10 : 1.0)
                .foregroundStyle(foregroundColor.source())
                .appFont(with: .BODY_B10)
                .contentTransition(.symbolEffect(.replace))
            
            Text(self.tab.title)
                .scaleEffect(isSelectedTab ? 1.10 : 1.0)
                .foregroundStyle(foregroundColor.source())
                .appFont(with: .BODY_B1)
                .fontWeight(isSelectedTab ? .semibold : .regular)
                .transition(.opacity)
                .id(self.tab.title)
            
        }
        .onTapGesture {
            
            Haptics.shared.vibrate(option: .selection)
            
            withAnimation(.spring) {
                self.selectedTab = self.tab
            }
            
        }
        
    }
    
}
