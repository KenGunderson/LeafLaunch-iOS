//
//  StandardTabBarView.swift
//  SwiftUIDemo
//
//  Created by Sako Hovaguimian on 4/17/24.
//

import SwiftUI

struct StandardTabBarView: View {
    
    @Binding var selectedTab: Tab

    var body: some View {
        
        VStack {
            
            HStack {
                
                ForEach(Tab.allCases, id: \.rawValue) { tab in
                    
                    TabItemView(
                        tab: tab,
                        selectedTab: self.$selectedTab
                    )
                    .frame(maxWidth: .infinity)
                    
                }
                
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 12)
            .padding(.bottom, 4)
            .background(Style.shared.background(.primary).source())
            .overlay(alignment: .top) {
                Rectangle().fill(Style.shared.background(.quaternary).source())
                    .frame(height: 1)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 1)
            }
            
        }
        .background(.clear)
        
    }
    
}
