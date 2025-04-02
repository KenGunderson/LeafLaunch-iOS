//
//  ContentView.swift
//  Rune
//
//  Created by Sako Hovaguimian on 4/1/25.
//

// TODO: -
/// Move Infrastructure from GP, move newer Components from SwiftyUI
/// Get Spacing / Colors / Fonts / Image Source / Background Style / Shadows /Etc
/// Get Base Views Adapt them to use AppBackgroundStyle etc...
/// Image Views / Progress Bars / Common Tools
/// Adapt them all to use ENV theme
/// Consolidate AppBackgroundStyle + AppForegroundStyle into ColorSource
/// Eventually Support Services -> From GP
///
/// IMPORTANT:
/// We need to not just use ThemeManager downstream, but also allow those properties to be in initializers to
/// set overrides if the user wants to. ThemeEngine or raw property.
/// Add Shadow color to Theme

import SwiftUI

extension Int: @retroactive Identifiable {
    
    public var id: Self {
        return self.hashValue
    }
    
}

struct ContentView: View {
    
    @Environment(\.themeManager) var themeManager: ThemeManager
    
    @State var selectedValue: Int? = 1
    private var values: [Int] = Array(1...3)
    
    var body: some View {
        
        AppBaseView {
            
            ScrollView {
            
                VStack(spacing: Spacing.medium.value) {
                    
                    Text("Rune")
                        .appFont(with: .billboard(.b1))
                        .foregroundStyle(self.themeManager.textColor(.title))
                    
                    Image(systemName: "globe")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 64)
                        .foregroundStyle(self.themeManager.theme.accentColorGradient)
                        .padding(.bottom, .small)
                    
                    CommonTextFieldPreview()
                    
                    Group {
                        
                        CommonSegmentedControl(
                            selectedOption: self.$selectedValue,
                            options: self.values,
                            backgroundStyle: .color(self.themeManager.background(.tertiary))
                        )
                        
                        CommonButton(title: "Gold Theme", icon: Image(systemName: "sun.max.fill"), backgroundStyle: .color(self.themeManager.theme.accentColor)) {
                            updateTheme(.GOLD_NAVY)
                        }
                        
                        CommonButton(
                            title: "Blue Theme",
                            titleColor: .color(themeManager.textColor(.title)),
                            icon: Image(systemName: "heart.fill"),
                            backgroundStyle: .color(themeManager.accentColor())
                        ) {
                            updateTheme(.BLUE)
                        }
                        
                        CommonButton(title: "Purple Theme", icon: Image(systemName: "moon.fill")) {
                            updateTheme(.INDIGO)
                        }
                        
                        CommonImageView(style: .image(Image(.image2)))
                            .scaledToFill()
                            .clipShape(.rect(cornerRadius: CornerRadius.small.rawValue))
                            .frame(maxHeight: 200)
                            .asButton {
                                print("DID SOMETHING")
                            }
                        
                        CommonImageView(style: .image(Image(systemName: "person.fill")))
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(themeManager.accentColor())
                            .frame(height: 64)
                        
                        ProgressSlider(
                            value: .constant(0.50),
                            trackStyle: .color(self.themeManager.background(.tertiary)),
                            fillStyle: .color(self.themeManager.accentColor()),
                            thumbStyle: .color(self.themeManager.background(.quad)),
                            thumbCircleStyle: .color(self.themeManager.background(.primary)),
                            thumbHeight: 50
                        )
                        
                    }
                    .padding(.horizontal, .xLarge)
                    
                }
                
            }
            
        }
        
    }
    
    private func updateTheme(_ theme: Theme) {
        
        withAnimation(.smooth(duration: 1)) {
            
            self.themeManager
                .updateTheme(theme)
            
        }
        
    }
    
}

#Preview {
    
    ContentView()
        .environment(ThemeManager.shared)
    
}
