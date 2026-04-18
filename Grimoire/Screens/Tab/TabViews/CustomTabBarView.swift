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
                        
                        RoundedRectangle(cornerRadius: 16)
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

struct FloatingNameTransitionTabBar: View {
    
    @Binding var selectedTab: Tab
    @Namespace var namespace

    var body: some View {
        
        HStack(spacing: 0) {
            
            ForEach(Tab.allCases, id: \.rawValue) { tab in
                
                tabBarItem(tab)
                    .overlay {
                        
                        if self.selectedTab == tab {
                            
                            RoundedRectangle(cornerRadius: 99)
                                .fill(Style.shared.accent.source().opacity(0.1))
                                .padding(.vertical, -4)
                                .padding(.horizontal, 6)
                                .matchedGeometryEffect(id: "id", in: namespace)
                            
                        }
                        
                    }
                
            }
            
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Style.shared.background(.primary).source().opacity(1))
        .clipShape(.capsule)
        .padding(.horizontal, 24)
        .padding(.bottom, -16)
        .appShadow()
        
    }
    
    @ViewBuilder
    private func tabBarItem(_ tab: Tab) -> some View {
        
        let isSelectedTab = tab == self.selectedTab
        let foregroundColor: ColorSource = isSelectedTab ? Style.shared.accent : .color(.gray)
        
        HStack(spacing: 8) {
            
            if isSelectedTab {
                
                Image(systemName: isSelectedTab ? tab.selectedIcon : tab.unselectedIcon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 26, maxHeight: 28)
                    .foregroundStyle(foregroundColor.source())
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .opacity
                    ))
                
                Text(tab.title)
                    .foregroundStyle(foregroundColor.source())
                    .appFont(with: .TITLE_2)
                    .fontWeight(.semibold)
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).animation(.spring(duration: 1).delay(1)),
                        removal: .opacity
                    ))
                    .id(tab.title)
                
            } else {
                
                Image(systemName: isSelectedTab ? tab.selectedIcon : tab.unselectedIcon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 26, maxHeight: 28)
                    .foregroundStyle(foregroundColor.source())
                
            }
            
        }
        .fixedSize(horizontal: true, vertical: false)
        .padding(.horizontal, .medium)
        .animation(.bouncy, value: self.selectedTab)
        .onTapGesture {
            
            Haptics.shared.vibrate(option: .selection)
            
            withAnimation(.spring) {
                self.selectedTab = tab
            }
            
        }
        .frame(maxWidth: .infinity)
        
    }
    
}

#Preview {
    
    @Previewable @State var selectedTab: Tab = .tab1
    
    AppBaseView(backgroundStyle: Style.shared.background(.quaternary)) {
    
        VStack(spacing: 24) {
            
            TabBarView(
                selectedTab: $selectedTab,
                style: .standard
            )
            .padding(.horizontal, .large2)
            
            TabBarView(
                selectedTab: $selectedTab,
                style: .custom(FloatingNameTransitionTabBar(selectedTab: $selectedTab).asAnyView())
            )
            
            TabBarView(
                selectedTab: $selectedTab,
                style: .custom(FloatingTabBar(selectedTab: $selectedTab).asAnyView())
            )
            
            TabBarView(
                selectedTab: $selectedTab,
                style: .custom(FloatingTransitionTabBar(selectedTab: $selectedTab).asAnyView())
            )
            
        }
        
    }
    
}
