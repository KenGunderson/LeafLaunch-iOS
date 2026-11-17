//
//  LeafLaunchButton.swift
//  LeafLaunch
//

import SwiftUI

struct LeafLaunchButton: View {

    @Environment(\.style) private var style

    private let fillStyle: RNButtonStyle.FillStyle
    private let title: String
    private let titleColor: RNColorSource
    private let titleFont: RNTheme.FontKey
    private let icon: RNImageSource?
    private let iconAlignment: HorizontalAlignment
    private let size: LeafLaunchButtonSize
    private let backgroundStyle: RNColorSource
    private let isEnabled: Bool
    private let cornerRadius: RNTheme.RadiusKey
    private let disabledOpacity: Double
    private let verticalPadding: RNTheme.SpacingKey
    private let horizontalPadding: RNTheme.SpacingKey
    private let action: () -> Void

    init(style: RNButtonStyle.FillStyle = .fill,
         title: String,
         titleColor: RNColorSource = .text(.button),
         titleFont: RNTheme.FontKey = .TITLE_4,
         icon: RNImageSource? = nil,
         iconAlignment: HorizontalAlignment = .leading,
         size: LeafLaunchButtonSize = .standard,
         backgroundStyle: RNColorSource = .foreground(.primary),
         isEnabled: Bool = true,
         verticalPadding: RNTheme.SpacingKey? = nil,
         horizontalPadding: RNTheme.SpacingKey? = nil,
         cornerRadius: RNTheme.RadiusKey? = nil,
         disabledOpacity: Double = 0.8,
         action: @escaping () -> Void) {

        self.fillStyle = style
        self.title = title
        self.titleColor = titleColor
        self.titleFont = titleFont
        self.icon = icon
        self.iconAlignment = iconAlignment
        self.size = size
        self.backgroundStyle = backgroundStyle
        self.isEnabled = isEnabled
        self.cornerRadius = cornerRadius ?? (size == .prominent ? .medium2 : .medium)
        self.disabledOpacity = disabledOpacity
        self.verticalPadding = verticalPadding ?? LLSpacing.cardContent
        self.horizontalPadding = horizontalPadding ?? (size == .prominent ? LLSpacing.content : LLSpacing.groupedContent)
        self.action = action

    }

    var body: some View {

        label()
            .runePadding(.vertical, self.verticalPadding)
            .runePadding(.horizontal, self.horizontalPadding)
            .frame(maxWidth: .infinity)
            .background {
                background()
            }
            .runeCornerRadius(self.cornerRadius)
            .contentShape(.rect(cornerRadius: self.style.radius(self.cornerRadius)))
            .runeAsButton(action: self.action)
            .disabled(!self.isEnabled)
            .opacity(self.isEnabled ? 1 : self.disabledOpacity)

    }

    @ContentBuilder
    private func label() -> some View {

        let showsLeadingIcon = self.iconAlignment == .leading || self.size == .prominent
        let showsTrailingIcon = self.iconAlignment == .trailing || self.size == .prominent

        HStack(spacing: self.style.spacing(LLSpacing.groupedContent)) {

            if let icon = self.icon, showsLeadingIcon {

                iconView(icon)
                    .opacity(self.iconAlignment == .leading ? 1 : 0)

            }

            if self.size == .prominent {

                Text(self.title)
                    .runeFont(with: self.titleFont)
                    .frame(maxWidth: .infinity)
                    .minimumScaleFactor(0.75)

            } else {

                Text(self.title)
                    .runeFont(with: self.titleFont)

            }

            if let icon = self.icon, showsTrailingIcon {

                iconView(icon)
                    .opacity(self.iconAlignment == .trailing ? 1 : 0)

            }

        }
        .foregroundStyle(self.titleColor)
        .lineLimit(1)

    }

    @ContentBuilder
    private func iconView(_ icon: RNImageSource) -> some View {

        if self.size == .prominent {

            icon.view(shouldResize: false)
                .runeFont(with: self.titleFont)

        } else {

            icon.view()
                .fixedSize(
                    horizontal: true,
                    vertical: true
                )

        }

    }

    @ContentBuilder
    private func background() -> some View {

        let shape = RoundedRectangle(cornerRadius: self.style.radius(self.cornerRadius))

        switch self.fillStyle {
        case .fill:

            shape.fill(self.backgroundStyle)

        case .outline(let lineWidth):

            shape
                .fill(.backgroundTappable)
                .overlay {

                    shape.stroke(
                        self.backgroundStyle,
                        lineWidth: lineWidth
                    )

                }
        }

    }

}
