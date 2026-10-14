//
//  StoreThemeBuilder.swift
//  LeafLaunch
//

import SwiftUI

enum StoreThemeBuilder {

    static func makeTheme(branding: StoreAppBranding,
                          baseTheme: AvailableTheme) -> Theme? {

        guard let branding = validatedDefinition(branding: branding) else { return nil }

        let isLightMode = branding.backgroundColor.map(isLightColor) ?? baseTheme.theme().isLightMode
        let fallback = (isLightMode ? AvailableTheme.light : .dark).theme()
        let primary = colorSource(branding.primaryColor) ?? fallback.foreground.primary
        let accent = colorSource(branding.accentColor) ?? fallback.foreground.secondary
        let background = colorSource(branding.backgroundColor) ?? fallback.background.primary
        let text = colorSource(branding.textColor)
        let buttonText = branding.primaryColor.map {
            ColorSource.color(isLightColor($0) ? Color(hex: "#111827") : .white)
        } ?? fallback.textColor.button

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
            radius: .init(
                extraSmall: CGFloat(branding.radius?.extraSmall ?? Double(fallback.radius.extraSmall)),
                small: CGFloat(branding.radius?.small ?? Double(fallback.radius.small)),
                small2: CGFloat(branding.radius?.small2 ?? Double(fallback.radius.small2)),
                medium: CGFloat(branding.radius?.medium ?? Double(fallback.radius.medium)),
                medium2: CGFloat(branding.radius?.medium2 ?? Double(fallback.radius.medium2)),
                large: CGFloat(branding.radius?.large ?? Double(fallback.radius.large)),
                extraLarge: CGFloat(branding.radius?.extraLarge ?? Double(fallback.radius.extraLarge))
            ),
            fonts: .storeBranding(familyName: branding.fontFamily, fallback: fallback.fonts),
            shadow: fallback.shadow,
            buttonBounceStyle: fallback.buttonBounceStyle,
            alertStyle: fallback.alertStyle
        )

    }

    // Cache the same typed API definition with every supported radius resolved.
    // Rune's UI values remain reconstructed rather than serialized.
    static func validatedDefinition(branding: StoreAppBranding) -> StoreAppBranding? {

        let colorValues = [branding.primaryColor, branding.accentColor, branding.backgroundColor, branding.textColor]
        let mediaKeys = [branding.logoObjectKey, branding.iconObjectKey, branding.splashObjectKey]
        let mediaPrefix = "stores/\(BusinessConfig.businessId)/app/"
        let hasValidMedia = mediaKeys.compactMap { $0 }.allSatisfy {

            $0.hasPrefix(mediaPrefix) && !$0.contains("..") && $0.count <= 500

        }
        let hasValidFont = branding.fontFamily.map {
            !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && $0.count <= 100
        } ?? true

        guard colorValues.compactMap({ $0 }).allSatisfy(isValidHexColor),
              branding.radius?.isValid != false,
              hasValidMedia,
              hasValidFont else { return nil }

        let radius = branding.radius
        let fallback = LeafLaunchThemeTokens.radius

        return StoreAppBranding(
            primaryColor: branding.primaryColor,
            accentColor: branding.accentColor,
            backgroundColor: branding.backgroundColor,
            textColor: branding.textColor,
            logoObjectKey: branding.logoObjectKey,
            iconObjectKey: branding.iconObjectKey,
            splashObjectKey: branding.splashObjectKey,
            fontFamily: branding.fontFamily,
            radius: StoreAppRadius(
                extraSmall: radius?.extraSmall ?? Double(fallback.extraSmall),
                small: radius?.small ?? Double(fallback.small),
                small2: radius?.small2 ?? Double(fallback.small2),
                medium: radius?.medium ?? Double(fallback.medium),
                medium2: radius?.medium2 ?? Double(fallback.medium2),
                large: radius?.large ?? Double(fallback.large),
                extraLarge: radius?.extraLarge ?? Double(fallback.extraLarge)
            )
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
            branding.fontFamily ?? "",
            String(branding.radius?.extraSmall ?? 0),
            String(branding.radius?.small ?? 0),
            String(branding.radius?.small2 ?? 0),
            String(branding.radius?.medium ?? 0),
            String(branding.radius?.medium2 ?? 0),
            String(branding.radius?.large ?? 0),
            String(branding.radius?.extraLarge ?? 0)
        ].joined(separator: "|")

    }

}
