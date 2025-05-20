//
//  CustomTabBarView.swift
//  SwiftUIDemo
//
//  Created by Sako Hovaguimian on 4/17/24.
//

import SwiftUI

struct FloatingTabBar: View {
    
    @Binding var selectedTab: Tab

    var body: some View {
        
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
        .background(Style.shared.background(.primary).source().opacity(1))
        .cornerRadius(20)
        .padding(.horizontal, 24)
        .padding(.bottom, -16)
        .appShadow()
        
    }
    
}

struct FloatingTransitionTabBar: View {
    
    @Binding var selectedTab: Tab
    @Namespace var namespace

    var body: some View {
        
        HStack {
            
            ForEach(Tab.allCases, id: \.rawValue) { tab in
                
                TabItemView(
                    tab: tab,
                    selectedTab: self.$selectedTab
                )
                .frame(maxWidth: .infinity)
                .overlay {
                    
                    if self.selectedTab == tab {
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Style.shared.accent.source().opacity(0.1))
                            .padding(.vertical, -4)
                            .padding(.horizontal, 8)
                            .matchedGeometryEffect(id: "id", in: namespace)
                        
                    }
                    
                }
                
            }
            
        }
        .padding(.vertical, 12)
        .background(Style.shared.background(.primary).source().opacity(1))
        .cornerRadius(20)
        .padding(.horizontal, 24)
        .padding(.bottom, -16)
        .appShadow()
        
    }
    
}

#Preview {
    
    @Previewable @State var selectedTab: Tab = .tab1
    
    VStack {
        
        Spacer()
        
        TabBarView(
            selectedTab: $selectedTab,
            style: .custom(FloatingTransitionTabBar(selectedTab: $selectedTab).asAnyView())
        )
        
    }
    .ignoresSafeArea(.keyboard)
    
}
