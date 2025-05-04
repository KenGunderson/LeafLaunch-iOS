//
//  CustomTabBarView.swift
//  SwiftUIDemo
//
//  Created by Sako Hovaguimian on 4/17/24.
//

import SwiftUI

struct CustomTabBarView: View {
    
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
            .padding(.vertical, 12)
            .background(.thinMaterial)
            .cornerRadius(20)
            .padding(.horizontal, 24)
            
        }
        
    }
    
}
