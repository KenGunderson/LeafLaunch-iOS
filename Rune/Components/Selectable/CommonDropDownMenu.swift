//
//  CommonDropDownMenu.swift
//  Rune
//
//  Created by Sako Hovaguimian on 4/3/25.
//


import SwiftUI

struct CommonDropDownMenu<S: Selectable>: View {
    
    var options: [S]
    
    var menuWdith: CGFloat = 150
    var buttonHeight: CGFloat = 50
    var maxItemDisplayed: Int = 3
    var foregroundStyle: AppForegroundStyle = .color(ThemeManager.shared.textColor(.title))
    var backgroundStyle: AppBackgroundStyle = .color(ThemeManager.shared.background(.tertiary))

    @Binding var selectedOption: S?
    @Binding var showDropdown: Bool
    
    @State private var scrollPosition: S?
    
    var defaultTitle: String {
        self.selectedOption?.description ?? "Select One"
    }
    
    var body: some View {
        
        VStack {
            
            VStack(spacing: 0) {
                
                button(
                    title: defaultTitle,
                    icon: "chevron.down",
                    isSelected: true,
                    shouldRotate: self.showDropdown
                ) {
                    
                    withAnimation(.bouncy) {
                        showDropdown.toggle()
                    }
                    
                }
                .padding(.horizontal, 20)
                .frame(width: menuWdith, height: buttonHeight, alignment: .center)
                
                if (showDropdown) {
                    
                    let scrollViewHeight: CGFloat = options.count > maxItemDisplayed
                    ? (buttonHeight * CGFloat(maxItemDisplayed))
                    : (buttonHeight * CGFloat(options.count))
                    
                    ScrollView {
                        
                        items()
                            .scrollTargetLayout()
                        
                    }
                    .scrollPosition(id: $scrollPosition)
                    .scrollDisabled(options.count <=  3)
                    .frame(height: scrollViewHeight)
                    .onAppear {
                        scrollPosition = selectedOption
                    }
                    .scrollIndicators(.visible)
                    
                }
                
            }
            .foregroundStyle(self.foregroundStyle.foregroundStyle())
            .background(RoundedRectangle(cornerRadius: CornerRadius.medium.value).fill(backgroundStyle.backgroundStyle()))
            
        }
        .clipped()
        .appShadow()
        .frame(width: menuWdith, height: buttonHeight, alignment: .top)
        .zIndex(100)
        
    }
    
    private func items() -> some View {
        
        LazyVStack(spacing: 0) {
            
            ForEach(options, id: \.self) { option in
                
                button(
                    title: option.description,
                    icon: "checkmark.circle.fill",
                    isSelected: (selectedOption == option)) {
                        
                        withAnimation(.bouncy) {
                            
                            self.selectedOption = option
                            showDropdown.toggle()
                            
                        }
                        
                    }
                    .padding(.horizontal, 20)
                    .frame(
                        width: menuWdith,
                        height: buttonHeight,
                        alignment: .center
                    )
                
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
            
            HStack(spacing: Spacing.medium.value) {
                
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
        .foregroundStyle(self.foregroundStyle.foregroundStyle())
        
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
                    menuWdith: 200,
                    selectedOption: $selectedOption,
                    showDropdown: $showDropdown
                )
                
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
            .foregroundStyle(ThemeManager.shared.textColor(.title))
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
