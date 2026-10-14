//
//  StoreThemeBuilder.swift
//  LeafLaunch
//

import SwiftUI

enum StoreThemeBuilder {

    static func makeTheme(branding: StoreAppBranding,
                          baseTheme: AvailableTheme) -> Theme? {

        guard let branding = validatedDefinition(branding: branding) else { return nil }

        let isLightMode = branding.backgroundColor.map { StoreThemeColor.lightness($0) >= 0.6 } ?? baseTheme.theme().isLightMode
        let fallback = (isLightMode ? AvailableTheme.light : .dark).theme()
        guard let background = hexColor(fallback.background.primary),
              let contentBackground = hexColor(fallback.background.secondary),
              let title = hexColor(fallback.textColor.title),
              let body = hexColor(fallback.textColor.body),
              let accent = hexColor(fallback.palette.link),
              let button = hexColor(fallback.foreground.primary),
              let icon = hexColor(fallback.foreground.secondary) else { return nil }

        let colors = StoreThemeColors.resolve(
            branding: branding,
            defaults: StoreThemeBaseColors(background: background,
                                           contentBackground: contentBackground,
                                           title: title,
                                           body: body,
                                           accent: accent,
                                           button: button,
                                           icon: icon)
        )

        return Theme(
            id: themeId(branding: branding, baseTheme: baseTheme),
            isLightMode: isLightMode,
            foreground: .init(
                primary: colorSource(colors.foreground["primary"]) ?? fallback.foreground.primary,
                secondary: colorSource(colors.foreground["secondary"]) ?? fallback.foreground.secondary,
                tertiary: colorSource(colors.foreground["tertiary"]) ?? fallback.foreground.tertiary,
                quaternary: colorSource(colors.foreground["quaternary"]) ?? fallback.foreground.quaternary,
                disabled: colorSource(colors.foreground["disabled"]) ?? fallback.foreground.disabled
            ),
            background: .init(
                primary: colorSource(colors.background["primary"]) ?? fallback.background.primary,
                secondary: colorSource(colors.background["secondary"]) ?? fallback.background.secondary,
                tertiary: colorSource(colors.background["tertiary"]) ?? fallback.background.tertiary,
                quaternary: colorSource(colors.background["quaternary"]) ?? fallback.background.quaternary,
                quinary: colorSource(colors.background["quinary"]) ?? fallback.background.quinary,
                border: colorSource(colors.background["border"]) ?? fallback.background.border
            ),
            textColor: .init(
                title: colorSource(colors.textColor["title"]) ?? fallback.textColor.title,
                titleInverted: colorSource(colors.textColor["titleInverted"]) ?? fallback.textColor.titleInverted,
                body: colorSource(colors.textColor["body"]) ?? fallback.textColor.body,
                bodyInverted: colorSource(colors.textColor["bodyInverted"]) ?? fallback.textColor.bodyInverted,
                button: colorSource(colors.textColor["button"]) ?? fallback.textColor.button,
                placeholder: colorSource(colors.textColor["placeholder"]) ?? fallback.textColor.placeholder
            ),
            palette: .init(
                success: fallback.palette.success,
                warning: fallback.palette.warning,
                error: fallback.palette.error,
                info: fallback.palette.info,
                link: colorSource(colors.palette["link"]) ?? fallback.palette.link,
                highlight: colorSource(colors.palette["highlight"]) ?? fallback.palette.highlight,
                premium: fallback.palette.premium,
                destructive: fallback.palette.destructive,
                online: fallback.palette.online,
                offline: fallback.palette.offline,
                skeleton: colorSource(colors.palette["skeleton"]) ?? fallback.palette.skeleton
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

        let colorValues = [branding.contentBackgroundColor, branding.titleColor, branding.bodyColor, branding.iconColor, branding.accentColor, branding.buttonColor, branding.buttonTitleColor, branding.backgroundColor]
        let mediaKeys = [branding.logoObjectKey, branding.iconObjectKey, branding.splashObjectKey]
        let mediaPrefix = "stores/\(BusinessConfig.businessId)/app/"
        let hasValidMedia = mediaKeys.compactMap { $0 }.allSatisfy {

            $0.hasPrefix(mediaPrefix) && !$0.contains("..") && $0.count <= 500

        }
        guard colorValues.compactMap({ $0 }).allSatisfy(isValidHexColor),
              branding.radius?.isValid != false,
              hasValidMedia else { return nil }

        let radius = branding.radius
        let fallback = LeafLaunchThemeTokens.radius

        return StoreAppBranding(
            contentBackgroundColor: branding.contentBackgroundColor,
            titleColor: branding.titleColor,
            bodyColor: branding.bodyColor,
            iconColor: branding.iconColor,
            accentColor: branding.accentColor,
            buttonColor: branding.buttonColor,
            buttonTitleColor: branding.buttonTitleColor,
            backgroundColor: branding.backgroundColor,
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

    private static func hexColor(_ source: ColorSource) -> String? {

        guard let color = source.asColor else { return nil }
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        guard UIColor(color).getRed(&red, green: &green, blue: &blue, alpha: &alpha) else { return nil }
        return String(format: "#%02X%02X%02X", Int((red * 255).rounded()), Int((green * 255).rounded()), Int((blue * 255).rounded()))

    }

    private static func themeId(branding: StoreAppBranding, baseTheme: AvailableTheme) -> String {

        [
            "store-rune-color-v1",
            BusinessConfig.businessId,
            baseTheme.rawValue,
            branding.contentBackgroundColor ?? "",
            branding.titleColor ?? "",
            branding.bodyColor ?? "",
            branding.iconColor ?? "",
            branding.accentColor ?? "",
            branding.buttonColor ?? "",
            branding.buttonTitleColor ?? "",
            branding.backgroundColor ?? "",
            branding.fontFamily?.rawValue ?? "",
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
