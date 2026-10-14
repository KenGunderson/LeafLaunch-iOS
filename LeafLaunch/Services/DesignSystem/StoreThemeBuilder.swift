//
//  StoreThemeBuilder.swift
//  LeafLaunch
//

import SwiftUI

enum StoreThemeBuilder {

    static func makeTheme(branding: StoreAppBranding,
                          baseTheme: AvailableTheme) -> Theme? {

        let colorValues = [branding.primaryColor, branding.accentColor, branding.backgroundColor, branding.textColor]

        guard colorValues.compactMap({ $0 }).allSatisfy(isValidHexColor) else { return nil }

        let isLightMode = branding.backgroundColor.map(isLightColor) ?? baseTheme.theme().isLightMode
        let fallback = (isLightMode ? AvailableTheme.light : .dark).theme()
        let primary = colorSource(branding.primaryColor) ?? fallback.foreground.primary
        let accent = colorSource(branding.accentColor) ?? fallback.foreground.secondary
        let background = colorSource(branding.backgroundColor) ?? fallback.background.primary
        let text = colorSource(branding.textColor)
        let buttonText = branding.primaryColor.map {
            ColorSource.color(isLightColor($0) ? Color(hex: "#111827") : .white)
        } ?? fallback.textColor.button

        // The current API branding schema has no radius, spacing, or shadow
        // fields. Preserve the built-in Rune tokens for those roles.
        return Theme(
            id: themeId(branding: branding, baseTheme: baseTheme),
            isLightMode: isLightMode,
            foreground: .init(
                primary: primary,
                secondary: accent,
                tertiary: fallback.foreground.tertiary,
                quaternary: fallback.foreground.quaternary,
                disabled: fallback.foreground.disabled
            ),
            background: .init(
                primary: background,
                secondary: fallback.background.secondary,
                tertiary: fallback.background.tertiary,
                quaternary: fallback.background.quaternary,
                quinary: fallback.background.quinary,
                border: fallback.background.border
            ),
            textColor: .init(
                title: text ?? fallback.textColor.title,
                titleInverted: fallback.textColor.titleInverted,
                body: text ?? fallback.textColor.body,
                bodyInverted: fallback.textColor.bodyInverted,
                button: buttonText,
                placeholder: fallback.textColor.placeholder
            ),
            palette: .init(
                success: fallback.palette.success,
                warning: fallback.palette.warning,
                error: fallback.palette.error,
                info: fallback.palette.info,
                link: primary,
                highlight: accent,
                premium: fallback.palette.premium,
                destructive: fallback.palette.destructive,
                online: fallback.palette.online,
                offline: fallback.palette.offline,
                skeleton: fallback.palette.skeleton
            ),
            spacing: fallback.spacing,
            radius: fallback.radius,
            fonts: .storeBranding(familyName: branding.fontFamily, fallback: fallback.fonts),
            shadow: fallback.shadow,
            buttonBounceStyle: fallback.buttonBounceStyle,
            alertStyle: fallback.alertStyle
        )

    }

    private static func colorSource(_ hex: String?) -> ColorSource? {
        hex.map { .color(Color(hex: $0)) }
    }

    private static func isValidHexColor(_ hex: String) -> Bool {
        hex.range(of: "^#[0-9a-fA-F]{6}$", options: .regularExpression) != nil
    }

    private static func isLightColor(_ hex: String) -> Bool {

        guard let value = UInt32(hex.dropFirst(), radix: 16) else { return true }
        let red = Double((value >> 16) & 0xFF) / 255
        let green = Double((value >> 8) & 0xFF) / 255
        let blue = Double(value & 0xFF) / 255

        return (0.2126 * red) + (0.7152 * green) + (0.0722 * blue) > 0.5

    }

    private static func themeId(branding: StoreAppBranding, baseTheme: AvailableTheme) -> String {

        [
            "store",
            BusinessConfig.businessId,
            baseTheme.rawValue,
            branding.primaryColor ?? "",
            branding.accentColor ?? "",
            branding.backgroundColor ?? "",
            branding.textColor ?? "",
            branding.fontFamily ?? ""
        ].joined(separator: "|")

    }

}
