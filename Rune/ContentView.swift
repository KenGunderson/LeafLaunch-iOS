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
///
///
/// NOTES:
/// Could we move shadow + spacing + font styles etc. to a plist and have it directly applied to theme to make it a dynamic setup

import SwiftUI

extension Int: @retroactive Identifiable {
    
    public var id: Self {
        return self.hashValue
    }
    
}

struct ContentView: View {
    
    @Environment(\.themeManager) var themeManager: ThemeManager
    
    // Picker
    
    @State var selectedValue: Int? = 1
    private var values: [Int] = Array(1...3)
    
    // Slider
    
    @State var sliderValue: Double = 0.8
    
    var body: some View {
        
        AppBaseView {
            
            ScrollView {
                
                VStack(spacing: Spacing.large.value) {
                    
                    Text("Rune")
                        .appFont(with: .billboard(.b1))
                        .foregroundStyle(self.themeManager.textColor(.title))
                    
                    Image(systemName: "globe")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 64)
                        .foregroundStyle(self.themeManager.theme.accentColorGradient)
                        .padding(.bottom, .small)
                    
                    Group {
                        
                        pickers()
                        textfields()
                        buttons()
                        images()
                        sliders()
                        
                    }
                    .padding(.horizontal, .large)
                    
                    colorThemeGrid()
                    
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, .custom(64))
                
            }
            
        }
        
    }
    
    private func pickers() -> some View {
        
        CommonSegmentedControl(
            selectedOption: self.$selectedValue,
            options: self.values,
            backgroundStyle: .color(self.themeManager.background(.tertiary))
        )
        
    }
    
    private func images() -> some View {
        
        VStack(spacing: Spacing.medium.value) {
            
            CommonImageView(style: .image(Image(.image2)))
                .scaledToFill()
                .clipShape(.rect(cornerRadius: CornerRadius.small.rawValue))
                .frame(maxHeight: 200)
                .asButton {}
            
            CommonImageView(style: .image(Image(systemName: "person.fill")))
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(themeManager.accentColor())
                .frame(height: 64)
            
        }
        
    }
    
    private func sliders() -> some View {
        
        ProgressSlider(
            value: self.$sliderValue,
            trackStyle: .color(self.themeManager.background(.tertiary)),
            fillStyle: .color(self.themeManager.accentColor()),
            thumbStyle: .color(self.themeManager.background(.quad)),
            thumbCircleStyle: .color(self.themeManager.accentColor()),
            thumbHeight: 36
        )
        
    }
    
    private func textfields() -> some View {
        
        CommonTextFieldPreview()
        
    }
    
    private func buttons() -> some View {
        
        VStack(spacing: Spacing.medium.value) {
            
            CommonButton(title: "Gold Theme", icon: Image(systemName: "sun.max.fill"), backgroundStyle: .color(self.themeManager.theme.accentColor)) {
                updateTheme(.GOLD_NAVY)
            }
            
            CommonButton(title: "Emerald Forest", icon: Image(systemName: "sun.max.fill"), backgroundStyle: .color(self.themeManager.theme.accentColor)) {
                updateTheme(.EMERALD_NOIR)
            }
            
            CommonButton(title: "Coral Twilight", icon: Image(systemName: "sun.max.fill"), backgroundStyle: .color(self.themeManager.theme.accentColor)) {
                updateTheme(.CORAL_TWILIGHT)
            }
            
            CommonButton(title: "Neon Night", icon: Image(systemName: "sun.max.fill"), backgroundStyle: .color(self.themeManager.theme.accentColor)) {
                updateTheme(.NEON_NIGHT)
            }
            
            CommonButton(
                title: "Sandstone Dusk",
                titleColor: .color(themeManager.textColor(.title)),
                icon: Image(systemName: "heart.fill"),
                backgroundStyle: .color(themeManager.accentColor())
            ) {
                updateTheme(.SANDSTONE_DUSK)
            }
            
        }
        
    }
    
    private func colorThemeGrid() -> some View {
        
        VStack(alignment: .leading, spacing: Spacing.medium.value) {
            
            colorScrollView(
                title: "Accent",
                colors: [
                    self.themeManager.accentColor()
                ]
            )
            
            colorScrollView(
                title: "Background",
                colors: [
                    self.themeManager.background(.primary),
                    self.themeManager.background(.secondary),
                    self.themeManager.background(.tertiary),
                    self.themeManager.background(.quad)
                ]
            )
            
            colorScrollView(
                title: "Text",
                colors: [
                    self.themeManager.textColor(.title),
                    self.themeManager.textColor(.titleInverted),
                    self.themeManager.textColor(.body),
                    self.themeManager.textColor(.bodyInverted)
                ]
            )
            
        }
        .padding(.vertical, .medium)
        .background(.white.opacity(0.1))
        .padding(.vertical, .medium)
        
    }
    
    private func colorScrollView(title: String, colors: [Color]) -> some View {
        
        VStack(alignment: .leading) {
            
            Text(title)
                .appFont(with: .title(.t8))
                .foregroundStyle(self.themeManager.textColor(.title))
                .padding(.horizontal, .medium)
            
            ScrollView(.horizontal) {
                
                HStack {
                       
                    ForEach(colors, id: \.description) { color in
                        colorItem(color)
                    }
                    
                }
                
            }
            .frame(maxWidth: .infinity)
            .safeAreaPadding(.horizontal, Spacing.medium.value)
            
        }
        
    }
    
    private func colorItem(_ color: Color) -> some View {
        
        RoundedRectangle(cornerRadius: CornerRadius.small.value)
            .fill(color)
            .frame(width: 120, height: 120)
            .aspectRatio(contentMode: .fit)
        
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
