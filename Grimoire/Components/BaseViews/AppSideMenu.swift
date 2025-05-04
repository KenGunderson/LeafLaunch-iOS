//
//  SideMenu.swift
//  Rune
//
//  Created by Sako Hovaguimian on 4/12/25.
//


import SwiftUI

struct AppSideMenu<Content: View>: View {
    
    @Binding var isVisible: Bool
    private let content: Content
    
    public init(isSidebarVisible: Binding<Bool>,
                @ViewBuilder content: () -> Content) {
        
        self._isVisible = isSidebarVisible
        self.content = content()
        
    }
    
    var body: some View {
        
        ZStack {
            
            GeometryReader { _ in
                EmptyView()
            }
            .background(.black.opacity(0.3))
            .opacity(self.isVisible ? 1 : 0)
            .animation(.easeInOut.delay(0), value: self.isVisible)
            .onTapGesture {
                self.isVisible.toggle()
            }
            
            sideViewContent()
            
        }
        .edgesIgnoringSafeArea(.all)

    }
    
    private func sideViewContent() -> some View {
        
        HStack(alignment: .top) {
            
            self.content
                .fixedSize(
                    horizontal: false,
                    vertical: false
                )
                .offset(
                    x: isVisible ? 0 : -UIScreen.main.bounds.size.width
                )
                .animation(
                    .spring,
                    value: isVisible
                )
                        
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        
    }
    
}

#Preview {
    
    @Previewable @State var isSideBarOpened = false
    
    AppBaseView(alignment: .top) {
        
        Group {
            
            Button {
                isSideBarOpened.toggle()
            } label: {
                
                Label(
                    "Toggle SideBar",
                    systemImage: "line.3.horizontal.circle.fill"
                )
                
            }
            
            AppSideMenu(isSidebarVisible: $isSideBarOpened) {
                
                Style
                    .shared
                    .accent
                    .view()
                    .frame(width: 275)
                
            }
            
        }
        
    }
    
}
