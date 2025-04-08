//
//  CommonMultiSelectDropDown.swift
//  Rune
//
//  Created by Sako Hovaguimian on 4/5/25.
//

import SwiftUI

struct CommonDropDownMultiSelectMenu<S: Selectable>: View {
    
    let options: [S]
    
    var buttonHeight: CGFloat = 50
    var maxItemDisplayed: Int = 3
    var foregroundStyle: ColorSource = .color(ThemeManager.shared.textColor(.title))
    var backgroundStyle: ColorSource = .color(ThemeManager.shared.background(.tertiary))
    var cornerRadius: CornerRadius = .small
    var shouldPushContentDown: Bool = true

    @Binding var selectedOptions: Set<S>
    @Binding var showDropdown: Bool
    
    var selectionTitle: String {
        
        let count = self.selectedOptions.count
        let numberOfSelectionTitle = "\(count) Selected"
        let allSelectedTitle = "All Selected (\(count))"
        
        var title: String?
        
        if self.selectedOptions.count == self.options.count {
            title = allSelectedTitle
        } else if !self.selectedOptions.isEmpty {
            title = numberOfSelectionTitle
        }
        
        return title ?? "Select All That Apply"
        
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
                            .background(ThemeManager.shared.background(.quad))
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
                    .scrollDisabled(self.options.count <=  3)
                    .frame(height: self.showDropdown ? scrollViewHeight : 0)
                    .opacity(self.showDropdown ? 1 : 0)
                    .scrollIndicators(.visible)
                
            }
            .foregroundStyle(self.foregroundStyle.source())
            .background(RoundedRectangle(cornerRadius: self.cornerRadius.value).fill(self.backgroundStyle.source()))
            
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
                    isSelected: self.selectedOptions.contains(option)) {
                        
                        withAnimation(.smooth(duration: 0.5)) {
                            
                            if self.selectedOptions.contains(option) {
                                self.selectedOptions.remove(option)
                            } else {
                                self.selectedOptions.insert(option)
                            }
                            
                        }
                        
                    }
                    .padding(.horizontal, 20)
                    .frame(
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
                
                if isSelected {
                    
                    Image(systemName: icon)
                        .opacity(isSelected ? 1 : 0)
                        .rotationEffect(.degrees(shouldRotate ? -180 : 0))
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                    
                }
                
            }
            
        }
        .foregroundStyle(self.foregroundStyle.source())
        
    }
    
}

fileprivate struct CommonDropDownMultiSelectMenuView: View {
    
    @State private var selectedOptions: Set<String> = []
    @State private var showDropdown =  false
    
    let fruits = ["Charmander", "Squirtle", "Pikachu", "Bulbasaur"]
    
    var body: some  View {
        
        AppBaseView {
            
            VStack(spacing: 32) {
                
                CommonDropDownMultiSelectMenu(
                    options: fruits,
                    maxItemDisplayed: 10,
                    shouldPushContentDown: true,
                    selectedOptions: $selectedOptions,
                    showDropdown: $showDropdown
                )
                .frame(width: 280)
                
                if !selectedOptions.isEmpty {
                    Text("You have selected \(selectedOptions.joined(separator: ", "))")
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
    
    CommonDropDownMultiSelectMenuView()
    
}
