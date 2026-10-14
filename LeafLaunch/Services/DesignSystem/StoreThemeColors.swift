import Foundation

// Internal resolved hex values in Rune's existing groups. Only StoreAppBranding's
// eight base colors are persisted. iOS alone derives supporting shades.
nonisolated struct StoreThemeColors {

    let isLightMode: Bool
    let foreground: [String: String]
    let background: [String: String]
    let textColor: [String: String]
    let palette: [String: String]

    static func resolve(branding: StoreAppBranding, defaults: StoreThemeBaseColors) -> StoreThemeColors {

        let primary = branding.backgroundColor ?? defaults.background
        let secondary = branding.contentBackgroundColor ?? defaults.contentBackground
        let title = branding.titleColor ?? defaults.title
        let body = branding.bodyColor ?? defaults.body
        let icon = branding.iconColor ?? defaults.icon
        let accent = branding.accentColor ?? defaults.accent
        let button = branding.buttonColor ?? defaults.button
        let contentLightness = StoreThemeColor.lightness(secondary)
        let direction = contentLightness >= 0.5 ? -1.0 : 1.0
        let surfaceSeed = StoreThemeColor.mix(secondary, primary, secondWeight: 0.2)

        func surface(_ offset: Double, _ chroma: Double) -> String {
            StoreThemeColor.tone(surfaceSeed, lightness: contentLightness + direction * offset, chromaScale: chroma)
        }

        let tertiary = surface(0.04, 0.9)
        let quaternary = surface(0.08, 0.85)
        let quinary = surface(0.12, 0.8)
        let surfaces = [primary, secondary, tertiary, quaternary, quinary]
        let highlight = StoreThemeColor.tone(accent, lightness: StoreThemeColor.lightness(accent) + (StoreThemeColor.luminance(accent) >= 0.179 ? 0.06 : -0.06), chromaScale: 0.85)
        let onAccent = [accent, highlight]
        let iconBase = StoreThemeColor.contrasting(icon, backgrounds: surfaces, minimum: 4.5)

        func iconTone(_ offset: Double, _ chroma: Double) -> String {
            StoreThemeColor.tone(iconBase, lightness: StoreThemeColor.lightness(iconBase) - direction * offset, chromaScale: chroma)
        }

        return StoreThemeColors(
            isLightMode: StoreThemeColor.lightness(primary) >= 0.6,
            foreground: [
                "primary": button,
                "secondary": icon,
                "tertiary": StoreThemeColor.contrasting(iconTone(0.04, 0.85), backgrounds: surfaces, minimum: 3),
                "quaternary": StoreThemeColor.contrasting(iconTone(0.08, 0.7), backgrounds: surfaces, minimum: 3),
                "disabled": iconTone(0.16, 0.5)
            ],
            background: [
                "primary": primary,
                "secondary": secondary,
                "tertiary": tertiary,
                "quaternary": quaternary,
                "quinary": quinary,
                "border": surface(0.2, 0.7)
            ],
            textColor: [
                "title": title,
                "body": body,
                "placeholder": StoreThemeColor.contrasting(StoreThemeColor.tone(body, lightness: StoreThemeColor.lightness(body) - direction * 0.08, chromaScale: 0.7), backgrounds: surfaces, minimum: 4.5),
                "titleInverted": StoreThemeColor.contrasting(StoreThemeColor.tone(title, lightness: 1 - StoreThemeColor.lightness(title)), backgrounds: onAccent, minimum: 4.5),
                "bodyInverted": StoreThemeColor.contrasting(StoreThemeColor.tone(body, lightness: 1 - StoreThemeColor.lightness(body)), backgrounds: onAccent, minimum: 4.5),
                "button": branding.buttonTitleColor ?? StoreThemeColor.contrasting(title, backgrounds: [button], minimum: 4.5)
            ],
            palette: [
                "link": accent,
                "highlight": highlight,
                "skeleton": quaternary
            ]
        )

    }

}
