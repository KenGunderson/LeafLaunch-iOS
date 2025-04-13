//
//  ContentView.swift
//  Rune
//
//  Created by Sako Hovaguimian on 4/1/25.
//

import SwiftUI

/// TODO: -
///     Handle:
///         DEPRICATE AppFont.swift
/// 1. DraggableView 2. StringSource, 3. SlideButton, 4.ScrollBannerView, 5.Sidebar

struct ContentView: View {
    
    @Environment(\.style) var style: StyleProtocol
    
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
                
                VStack(spacing: Style.shared.spacing(.large)) {
                    
                    Text("Rune")
                        .appFont(with: .BILLBOARD_B1)
                        .foregroundStyle(self.style.textColor(.title).source())
                    
                    Image(systemName: "globe")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 64)
                        .foregroundStyle(self.style.accent.source())
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
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.medium)) {
            
            CommonSegmentedControl(
                selectedOption: self.$selectedValue,
                options: self.values,
                backgroundStyle: self.style.background(.tertiary)
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
        
        VStack(spacing: Style.shared.spacing(.medium)) {
            
            CommonImageView(style: .image((.image2)))
                .scaledToFill()
                .clipShape(.rect(cornerRadius: Style.shared.radius(.small)))
                .frame(maxHeight: 200)
                .asButton {}
            
            CommonImageView(style: .systemImage("person.fill"))
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(style.accent.source())
                .frame(height: 64)
            
        }
        
    }
    
    private func sliders() -> some View {
        
        VStack(spacing: Style.shared.spacing(.large)) {
            
            ProgressSlider(
                value: self.$sliderValue,
                trackStyle: self.style.background(.tertiary),
                fillStyle: self.style.accent,
                thumbStyle: self.style.background(.quaternary),
                thumbCircleStyle: self.style.accent,
                thumbHeight: 36
            )
            
            ProgressBar(
                value: .constant(Float(self.sliderValue)),
                trackColor: self.style.background(.tertiary),
                fillColor: self.style.accent
            )
            .frame(height: 16)

            ProgressBar(
                value: .constant(Float(self.sliderValue)),
                trackColor: self.style.background(.tertiary),
                fillColor: self.style.accent,
                clipShape: .init(.rect(cornerRadius: self.style.radius(.custom(2))))
            )
            .frame(height: 16)
            
            TextProgressBar(
                value: .constant(CGFloat(self.sliderValue)),
                text: "Text Progress Bar",
                textFont: .TITLE_T5,
                textColor: .color(.white),
                trackColor: self.style.background(.tertiary),
                fillColor: self.style.accent,
                cornerRadius: .small
            )
            
        }
        
    }
    
    private func textfields() -> some View {
        
        VStack(spacing: Style.shared.spacing(.medium)) {
            
            CommonTextFieldPreview()
            
            CommonTextEditView(
                text: $textEditText,
                placehoderText: "Placeholder...",
                isFocused: self.isTextEditFocused,
                titleColor: style.textColor(.title),
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
        
        VStack(spacing: Style.shared.spacing(.medium)) {
            
            CommonButton(
                title: "Gold Navy",
                icon: .systemImage("sun.max.fill"),
                backgroundStyle: self.style.accent
            ) {
                updateTheme(.GOLD_NAVY)
            }
            
            CommonButton(
                title: "Emerald Forest",
                icon: .systemImage("sun.max.fill"),
                backgroundStyle: self.style.accent
            ) {
                updateTheme(.EMERALD_NOIR)
            }
            
            CommonButton(title: "Massive Change",
                         icon: .systemImage("sun.max.fill"),
                         backgroundStyle: self.style.accent
            ) {
                updateTheme(.ALTERNATE)
            }
            
            CommonButton(
                title: "Gold Light",
                icon: .systemImage("sun.max.fill"),
                backgroundStyle: self.style.accent
            ) {
                updateTheme(.GOLD_LIGHT)
            }
            
            CommonButton(title: "Coral Twilight",
                         icon: .systemImage("sun.max.fill"),
                         backgroundStyle: self.style.accent
            ) {
                updateTheme(.CORAL_TWILIGHT)
            }
            
            CommonButton(title: "Neon Night",
                         icon: .systemImage("sun.max.fill"),
                         backgroundStyle: self.style.accent
            ) {
                updateTheme(.NEON_NIGHT)
            }
            
            CommonButton(
                title: "Sandstone Dusk",
                titleColor: style.textColor(.title),
                icon: .systemImage("heart.fill"),
                backgroundStyle: style.accent
            ) {
                updateTheme(.SANDSTONE_DUSK)
            }
            
            HStack {
                
                Text("Circular Icon View")
                    .appFont(with: .TITLE_T6)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(style.textColor(.title).source())
                
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
                    .appFont(with: .TITLE_T6)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(style.textColor(.title).source())
             
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
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.medium)) {
            
            InfoView(
                title: "Info View",
                foregroundStyle: self.style.accent
            )
            
            InfoView(
                title: "Info View Action",
                foregroundStyle: self.style.accent) {
                    
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
        
        VStack(spacing: Style.shared.spacing(.medium)) {
            
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
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.medium)) {
            
            colorScrollView(
                title: "Accent",
                colors: [
                    self.style.accent
                ]
            )
            
            colorScrollView(
                title: "Background",
                colors: [
                    self.style.background(.primary),
                    self.style.background(.secondary),
                    self.style.background(.tertiary),
                    self.style.background(.quaternary)
                ]
            )
            
            colorScrollView(
                title: "Text",
                colors: [
                    self.style.textColor(.title),
                    self.style.textColor(.titleInverted),
                    self.style.textColor(.body),
                    self.style.textColor(.bodyInverted)
                ]
            )
            
        }
        .padding(.vertical, .medium)
        .background(.white.opacity(0.1))
        
    }
    
    private func colorScrollView(title: String, colors: [ColorSource]) -> some View {
        
        VStack(alignment: .leading) {
            
            Text(title)
                .appFont(with: .TITLE_T8)
                .foregroundStyle(self.style.textColor(.title).source())
                .padding(.horizontal, .medium)
            
            ScrollView(.horizontal) {
                
                HStack {
                       
                    ForEach(colors, id: \.self) { color in
                        colorItem(color)
                    }
                    
                }
                
            }
            .frame(maxWidth: .infinity)
            .safeAreaPadding(.horizontal, Style.shared.spacing(.medium))
            
        }
        
    }
    
    private func colorItem(_ color: ColorSource) -> some View {
        
        RoundedRectangle(cornerRadius: Style.shared.radius(.small))
            .fill(color.source())
            .frame(width: 120, height: 120)
            .aspectRatio(contentMode: .fit)
        
    }
    
    private func filterView() -> some View {
        
        VStack(spacing: Style.shared.spacing(.medium)) {
            
            FiltersViewPreview(
                filters: self.dropDownValues,
                selectedFilter: self.$selectedFilterView,
                backgroundColor: style.background(.quaternary)
            )
            
            FiltersViewPreview(
                filters: self.dropDownValues,
                selectedFilter: self.$selectedFilterView,
                backgroundColor: style.background(.quaternary),
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
            
            self.style
                .updateTheme(theme)
            
        }
        
    }
    
}

#Preview {
    
    ContentView()
        .environment(Style.shared)
    
}
