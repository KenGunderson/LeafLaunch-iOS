//
//  LLSegmentedControl.swift
//  LeafLaunch
//

import SwiftUI

struct LLSegmentedControl<Option: RNSelectable>: View {

    @Environment(\.style) private var style

    @Binding private var selectedOption: Option?

    @Namespace private var selectionNamespace

    private let options: [Option]
    private let titleFont: RNTheme.FontKey
    private let selectedTextColor: RNColorSource
    private let unselectedTextColor: RNColorSource
    private let foregroundStyle: RNColorSource
    private let backgroundStyle: RNColorSource
    private let outerCornerRadius: RNTheme.RadiusKey
    private let innerCornerRadius: RNTheme.RadiusKey
    private let shadow: RNTheme.ShadowKey
    private let animation: Animation?

    init(selectedOption: Binding<Option?>,
         options: [Option],
         titleFont: RNTheme.FontKey = .TITLE_3,
         selectedTextColor: RNColorSource = .text(.button),
         unselectedTextColor: RNColorSource = .text(.title),
         foregroundStyle: RNColorSource = .foreground(.primary),
         backgroundStyle: RNColorSource = .background(.secondary),
         outerCornerRadius: RNTheme.RadiusKey = .small,
         innerCornerRadius: RNTheme.RadiusKey = .extraSmall,
         shadow: RNTheme.ShadowKey = .card,
         animation: Animation? = .smooth) {

        self._selectedOption = selectedOption
        self.options = options
        self.titleFont = titleFont
        self.selectedTextColor = selectedTextColor
        self.unselectedTextColor = unselectedTextColor
        self.foregroundStyle = foregroundStyle
        self.backgroundStyle = backgroundStyle
        self.outerCornerRadius = outerCornerRadius
        self.innerCornerRadius = innerCornerRadius
        self.shadow = shadow
        self.animation = animation

    }

    var body: some View {

        HStack(spacing: self.style.spacing(LLSpacing.none)) {

            ForEach(self.options) { option in
                segment(option)
            }

        }
        .runePadding(.horizontal, LLSpacing.compact)
        .background(self.backgroundStyle)
        .runeCornerRadius(self.outerCornerRadius)
        .runeShadow(self.shadow)

    }

    @ContentBuilder
    private func segment(_ option: Option) -> some View {

        let isSelected = self.selectedOption == option

        Text(option.description)
            .runeFont(with: self.titleFont)
            .foregroundStyle(isSelected ? self.selectedTextColor : self.unselectedTextColor)
            .runePadding(.vertical, LLSpacing.cardContent)
            .frame(maxWidth: .infinity, alignment: .center)
            .background {

                Group {

                    if isSelected {

                        RoundedRectangle(cornerRadius: self.style.radius(self.innerCornerRadius))
                            .fill(self.foregroundStyle)
                            .runePadding(.vertical, LLSpacing.compact)
                            .matchedGeometryEffect(
                                id: "selection",
                                in: self.selectionNamespace
                            )

                    }

                }
                .animation(
                    self.animation,
                    value: self.selectedOption
                )

            }
            .contentShape(.rect)
            .runeAsButton {
                self.selectedOption = option
            }

    }

}

#Preview {

    @Previewable @State var selected: String? = "Notes"

    LLSegmentedControl(
        selectedOption: $selected,
        options: ["Notes", "Activity"]
    )
    .runePadding(LLSpacing.pageInset)
    .withMockPreviews()

}
