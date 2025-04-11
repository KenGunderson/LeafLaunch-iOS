//
//  CommonDropDownMenu.swift
//  Rune
//
//  Created by Sako Hovaguimian on 4/3/25.
//

import SwiftUI

struct CommonDropDownMenu<S: Selectable>: View {
    
    var options: [S]
    
    var buttonHeight: CGFloat = 50
    var maxItemDisplayed: Int = 3
    var foregroundStyle: ColorSource = DesignSystem.shared.textColor(.title)
    var backgroundStyle: ColorSource = DesignSystem.shared.background(.tertiary)
    var cornerRadius: CustomTheme.RadiusKey = .small
    var shouldPushContentDown: Bool = true

    @Binding var selectedOption: S?
    @Binding var showDropdown: Bool
    
    @State private var scrollPosition: S?
    
    var selectionTitle: String {
        self.selectedOption?.description ?? "Select One"
    }
    
    var body: some View {
        
        VStack {
            
            VStack(spacing: 0) {
                
                button(
                    title: self.selectionTitle,
                    icon: "chevron.down",
                    isSelected: true,
                    shouldRotate: self.showDropdown
                ) {
                    
                    withAnimation(.smooth(duration: 0.5)) {
                        self.showDropdown.toggle()
                    }
                    
                }
                .padding(.horizontal, 20)
                .frame(height: self.buttonHeight, alignment: .center)
                .overlay(alignment: .bottom) {
                    
                    if self.showDropdown {
                        
                        Divider()
                            .frame(minHeight: 2)
                            .background(DesignSystem.shared.background(.quaternary).source())
                            .transition(.blurReplace)
                        
                    }
                    

                }
                    
                let scrollViewHeight: CGFloat = self.options.count > self.maxItemDisplayed
                    ? (buttonHeight * CGFloat(self.maxItemDisplayed))
                    : (buttonHeight * CGFloat(options.count))
                    
                    ScrollView {
                        
                        items()
                            .scrollTargetLayout()
                        
                    }
                    .scrollPosition(id: self.$scrollPosition)
                    .scrollDisabled(self.options.count <=  3)
                    .frame(height: self.showDropdown ? scrollViewHeight : 0)
                    .opacity(self.showDropdown ? 1 : 0)
                    .onAppear {
                        self.scrollPosition = selectedOption
                    }
                    .scrollIndicators(.visible)
                
            }
            .foregroundStyle(self.foregroundStyle.source())
            .background {
                
                RoundedRectangle(cornerRadius: DesignSystem.shared.radius(self.cornerRadius))
                    .fill(self.backgroundStyle.source())
                
            }
            
        }
        .appShadow()
        .frame(
            height: self.shouldPushContentDown ? nil : self.buttonHeight,
            alignment: .top
        )
        .zIndex(
            100
        )
        
    }
    
    private func items() -> some View {
        
        LazyVStack(spacing: 0) {
            
            ForEach(self.options) { option in
                
                button(
                    title: option.description,
                    icon: "checkmark.circle.fill",
                    isSelected: (selectedOption == option)) {
                        
                        withAnimation(.bouncy) {
                            
                            self.selectedOption = option
                            self.showDropdown.toggle()
                            
                        }
                        
                    }
                    .padding(.horizontal, 20)
                    .frame(
                        height: buttonHeight,
                        alignment: .center
                    )
                    .id(option)
                
            }
            
        }
        
    }
    
    private func button(title: String,
                        icon: String,
                        isSelected: Bool,
                        shouldRotate: Bool = false,
                        action: @escaping () -> ()) -> some View {
        
        Button {
            
            action()
            
        } label: {
            
            HStack(spacing: DesignSystem.shared.spacing(.medium)) {
                
                Text(title)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    .contentTransition(.numericText())
                    .appFont(with: .title(.t4))
                
                Image(systemName: icon)
                    .opacity(isSelected ? 1 : 0)
                    .rotationEffect(.degrees(shouldRotate ? -180 : 0))
                
            }
            
        }
        .foregroundStyle(self.foregroundStyle.source())
        
    }
    
}

fileprivate struct DropDownMenuDemo: View {
    
    @State private var selectedOption: String?
    @State private var showDropdown =  false
    
    let fruits = ["Charmander", "Squirtle", "Pikachu", "Bulbasaur"]
    
    var body: some  View {
        
        AppBaseView {
            
            VStack(spacing: 32) {
                
                CommonDropDownMenu(
                    options: fruits,
                    shouldPushContentDown: false,
                    selectedOption: $selectedOption,
                    showDropdown: $showDropdown
                )
                .frame(width: 180)
                
                if let selectedOption {
                    Text("You have selected \(selectedOption.description)")
                        .transition(.move(edge: .bottom))
                } else {
                    Text("Please Select Something")
                }
                
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .center
            )
            .foregroundStyle(DesignSystem.shared.textColor(.title).source())
            .onTapGesture {
                
                withAnimation(.bouncy) {
                    showDropdown = false
                }
                
            }
            
        }
        
    }
    
}

#Preview {
    
    DropDownMenuDemo()
    
}
