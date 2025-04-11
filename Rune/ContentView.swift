//
//  ContentView.swift
//  Rune
//
//  Created by Sako Hovaguimian on 4/1/25.
//

import SwiftUI

// MARK: - Todo items -
/// Move more views from SwiftyUI + GP into here
/// Move Design system to SwiftUI one
/// 1. DraggableView 2. StringSource, 3. SlideButton, 4.ScrollBannerView, 5.Sidebar

struct ContentView: View {
    
    @Environment(\.themeManager) var themeManager: ThemeManager
    
    // Picker
    
    @State var selectedValue: Int? = 1
    private var values: [Int] = Array(1...3)
    
    // Dropdown
    
    @State var shouldShowDropDown: Bool = false
    @State var selectedDropDownValue: String?
    @State private var dropDownValues: [String] = [
        "Pokemon",
        "Super Mario",
        "Sonic",
        "Mario Kart",
        "The Legend of Zelda",
        "Resident Evil",
        "Call of Duty",
        "FIFA",
        "NBA 2K"
    ]
    
    @State var shouldShowMultiSelectDropDown: Bool = false
    @State var selectedMultiSelectDropDownValues: Set<String> = []
    
    // Slider
    
    @State var sliderValue: Double = 0.8
    
    // Fields
    
    @State var textEditText: String = ""
    @FocusState private var isTextEditFocused: Bool
    
    @State var codeInputText: String = ""
    
    // Picker
    
    @State var selectedFilterView: String?
    
    // Loading
    
    @State var isLoading: Bool = false
    
    // RelativeBarSegments
    
    @State var items: [RelativeBarViewSegment] = [
        RelativeBarViewSegment(value: 300, title: "Apple", color: .color(.red)),
        RelativeBarViewSegment(value: 600, title: "Microsoft", color: .color(.green)),
        RelativeBarViewSegment(value: 200, title: "FNGU", color: .color(.blue))
    ]
    
    @State var itemsGradient: [RelativeBarViewSegment] = [
        RelativeBarViewSegment(value: 300, title: "Apple", color: .linearGradient(.redColor())),
        RelativeBarViewSegment(value: 600, title: "Microsoft", color: .linearGradient(.greenColor())),
        RelativeBarViewSegment(value: 200, title: "FNGU", color: .linearGradient(.blueColor()))
    ]
    
    @State var items2: [RelativeBarViewSegment] = [
        RelativeBarViewSegment(value: 300, title: "Apple", color: .color(.red)),
        RelativeBarViewSegment(value: 600, title: "Microsoft", color: .color(.green)),
        RelativeBarViewSegment(value: 200, title: "FNGU", color: .color(.blue)),
        RelativeBarViewSegment(value: 200, title: "SOXL", color: .color(.indigo))
    ]
    
    @State var items3: [RelativeBarViewSegment] = [
        RelativeBarViewSegment(value: 300, title: "Logic Pro X", color: .color(.red)),
        RelativeBarViewSegment(value: 200, title: "XCode", color: .color(.blue))
    ]
    
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
                        supportingViews()
                        sliders()
                        
                    }
                    .padding(.horizontal, .large)
                    
                    filterView()
                    relativeBarView()
                    colorThemeGrid()
                    
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, .custom(64))
                
            }
            .shimmer(self.isLoading)
            .redacted(reason: self.isLoading ? .placeholder : .invalidated)
            .allowsHitTesting(!self.isLoading)
            
        }
        .scrollDismissesKeyboard(.interactively)
        
    }
    
    private func pickers() -> some View {
        
        VStack(alignment: .leading, spacing: Spacing.medium.value) {
            
            CommonSegmentedControl(
                selectedOption: self.$selectedValue,
                options: self.values,
                backgroundStyle: .color(self.themeManager.background(.tertiary))
            )
            
            CommonDropDownMenu(
                options: self.dropDownValues,
                maxItemDisplayed: 3,
                selectedOption: self.$selectedDropDownValue,
                showDropdown: self.$shouldShowDropDown
            )
            
            CommonDropDownMultiSelectMenu(
                options: self.dropDownValues,
                maxItemDisplayed: 10,
                shouldPushContentDown: false,
                selectedOptions: self.$selectedMultiSelectDropDownValues,
                showDropdown: self.$shouldShowMultiSelectDropDown
            )
            
        }
        .zIndex(100)
        
    }
    
    private func images() -> some View {
        
        VStack(spacing: Spacing.medium.value) {
            
            CommonImageView(style: .image((.image2)))
                .scaledToFill()
                .clipShape(.rect(cornerRadius: CornerRadius.small.rawValue))
                .frame(maxHeight: 200)
                .asButton {}
            
            CommonImageView(style: .systemImage("person.fill"))
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(themeManager.accentColor())
                .frame(height: 64)
            
        }
        
    }
    
    private func sliders() -> some View {
        
        VStack(spacing: Spacing.large.value) {
            
            ProgressSlider(
                value: self.$sliderValue,
                trackStyle: .color(self.themeManager.background(.tertiary)),
                fillStyle: .color(self.themeManager.accentColor()),
                thumbStyle: .color(self.themeManager.background(.quad)),
                thumbCircleStyle: .color(self.themeManager.accentColor()),
                thumbHeight: 36
            )
            
            ProgressBar(
                value: .constant(Float(self.sliderValue)),
                trackColor: .color(self.themeManager.background(.tertiary)),
                fillColor: .color(self.themeManager.accentColor()),
                shouldRound: true
            )
            .frame(height: 16)
            
            TextProgressBar(
                value: .constant(CGFloat(self.sliderValue)),
                text: "Text Progress Bar",
                textFont: .title(.t5),
                textColor: .color(.white),
                trackColor: .color(self.themeManager.background(.tertiary)),
                fillColor: .color(self.themeManager.accentColor()),
                cornerRadius: .small
            )
            
        }
        
    }
    
    private func textfields() -> some View {
        
        VStack(spacing: Spacing.medium.value) {
            
            CommonTextFieldPreview()
            
            CommonTextEditView(
                text: $textEditText,
                placehoderText: "Placeholder...",
                isFocused: self.isTextEditFocused,
                titleColor: .color(ThemeManager.shared.textColor(.title)),
                lineLimit: 5...30
            )
            .focused(self.$isTextEditFocused)
            
            CommonCodeInputView(
                codeInput: $codeInputText,
                maxCharacterCount: 6
            )
            
        }
        
    }
    
    private func buttons() -> some View {
        
        VStack(spacing: Spacing.medium.value) {
            
            CommonButton(
                title: "Gold Theme",
                icon: .systemImage("sun.max.fill"),
                backgroundStyle: .color(self.themeManager.theme.accentColor)
            ) {
                updateTheme(.GOLD_NAVY)
            }
            
            CommonButton(
                title: "Emerald Forest",
                icon: .systemImage("sun.max.fill"),
                backgroundStyle: .color(self.themeManager.theme.accentColor)
            ) {
                updateTheme(.EMERALD_NOIR)
            }
            
            CommonButton(title: "Coral Twilight",
                         icon: .systemImage("sun.max.fill"),
                         backgroundStyle: .color(self.themeManager.theme.accentColor)
            ) {
                updateTheme(.CORAL_TWILIGHT)
            }
            
            CommonButton(title: "Neon Night",
                         icon: .systemImage("sun.max.fill"),
                         backgroundStyle: .color(self.themeManager.theme.accentColor)
            ) {
                updateTheme(.NEON_NIGHT)
            }
            
            CommonButton(
                title: "Sandstone Dusk",
                titleColor: .color(themeManager.textColor(.title)),
                icon: .systemImage("heart.fill"),
                backgroundStyle: .color(themeManager.accentColor())
            ) {
                updateTheme(.SANDSTONE_DUSK)
            }
            
            HStack {
                
                Text("Circular Icon View")
                    .appFont(with: .title(.t6))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(ThemeManager.shared.textColor(.title))
                
                CircularIconView(
                    size: 48,
                    imageSource: .systemImage("person.fill")
                )
                
                BackButton(size: 48) {}
                FavoriteButton(isFavorited: true, size: 48) {
                    
                    withAnimation(.bouncy(duration: 0.3)) {
                        self.isLoading = true
                    }
                                  
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        
                        withAnimation(.bouncy(duration: 0.3)) {
                            self.isLoading = false
                        }
                                      
                    }
                    
                }
                
            }
            
            HStack {
                
                Text("Avatar View")
                    .appFont(with: .title(.t6))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(ThemeManager.shared.textColor(.title))
             
                AvatarView(style: .initials(name: "Sako Hovaguimian"))
                    .frame(width: 48, height: 48)
                
                AvatarView(
                    style: .initials(name: "Sako Hovaguimian"),
                    clipShape: .init(.rect(cornerRadius: 8))
                )
                .frame(width: 48, height: 48)
                
                AvatarView(style: .image(.systemImage("person.fill")))
                    .frame(width: 48, height: 48)
                
                AvatarView(style: .image(.image(.prize)))
                    .frame(width: 48, height: 48)
                
            }
            
        }
        
    }
    
    private func supportingViews() -> some View {
        
        VStack(alignment: .leading, spacing: Spacing.medium.value) {
            
            InfoView(
                title: "Info View",
                foregroundStyle: .color(self.themeManager.accentColor())
            )
            
            InfoView(
                title: "Info View Action",
                foregroundStyle: .color(self.themeManager.accentColor())) {
                    
                    withAnimation(.spring) {
                        self.dropDownValues = ["Value 1", "Value 2", "Value 3", "Value 4", "Value 5"]
                    }
                    
                }
            
            if !self.dropDownValues.isEmpty {
                
                WStack {
                    
                    ForEach(dropDownValues) { text in
                        
                        TokenView(text: text)
                            .asButton {
                                
                                withAnimation(.spring) {
                                    self.dropDownValues.removeAll(where: { $0 == text })
                                }
                                
                            }
                        
                    }
                    
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                
            }
            
        }
        
    }
    
    private func relativeBarView() -> some View {
        
        VStack(spacing: Spacing.medium.value) {
            
            RelativeBarView(
                segments: items,
                mode: .relativeFill,
                cornerRadius: .small,
                shouldShowTitles: false,
                showLegend: true
            )
            
            RelativeBarView(
                segments: itemsGradient,
                mode: .relativeFill,
                cornerRadius: .small,
                shouldShowTitles: true,
                showLegend: false
            )
            
            RelativeBarView(
                segments: items2,
                mode: .relativeFill,
                cornerRadius: .small,
                showLegend: true
            )
            
            RelativeBarView(
                segments: items3,
                mode: .fixed(maxValue: 1000),
                cornerRadius: .small,
                showLegend: true
            )
            
        }
        .padding(.horizontal, .large)
        
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
        
    }
    
    private func colorScrollView(title: String, colors: [Color]) -> some View {
        
        VStack(alignment: .leading) {
            
            Text(title)
                .appFont(with: .title(.t8))
                .foregroundStyle(self.themeManager.textColor(.title))
                .padding(.horizontal, .medium)
            
            ScrollView(.horizontal) {
                
                HStack {
                       
                    ForEach(colors, id: \.self) { color in
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
    
    private func filterView() -> some View {
        
        VStack(spacing: Spacing.medium.value) {
            
            FiltersViewPreview(
                filters: self.dropDownValues,
                selectedFilter: self.$selectedFilterView,
                backgroundColor: .color(ThemeManager.shared.background(.quad))
            )
            
            FiltersViewPreview(
                filters: self.dropDownValues,
                selectedFilter: self.$selectedFilterView,
                backgroundColor: .color(ThemeManager.shared.background(.quad)),
                strokeStyle: true
            )
            
            PageIndicatorView(
                selectedIndex: 0,
                numberOfItems: 5
            )
            
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
