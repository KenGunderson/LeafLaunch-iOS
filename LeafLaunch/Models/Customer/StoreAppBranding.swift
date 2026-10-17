import Foundation

nonisolated struct StoreAppBranding: Codable, Equatable, Sendable {

    let contentBackgroundColor: String?
    let titleColor: String?
    let bodyColor: String?
    let iconColor: String?
    let accentColor: String?
    let buttonColor: String?
    let buttonTitleColor: String?
    let backgroundColor: String?
    let logoURL: URL?
    let iconURL: URL?
    let splashURL: URL?
    let fontFamily: StoreAppFontFamily?
    let radius: StoreAppRadius?

    init(contentBackgroundColor: String? = nil,
         titleColor: String? = nil,
         bodyColor: String? = nil,
         iconColor: String? = nil,
         accentColor: String? = nil,
         buttonColor: String? = nil,
         buttonTitleColor: String? = nil,
         backgroundColor: String? = nil,
         logoURL: URL? = nil,
         iconURL: URL? = nil,
         splashURL: URL? = nil,
         fontFamily: StoreAppFontFamily? = nil,
         radius: StoreAppRadius? = nil) {

        self.contentBackgroundColor = contentBackgroundColor
        self.titleColor = titleColor
        self.bodyColor = bodyColor
        self.iconColor = iconColor
        self.accentColor = accentColor
        self.buttonColor = buttonColor
        self.buttonTitleColor = buttonTitleColor
        self.backgroundColor = backgroundColor
        self.logoURL = logoURL
        self.iconURL = iconURL
        self.splashURL = splashURL
        self.fontFamily = fontFamily
        self.radius = radius

    }

    private enum CodingKeys: String, CodingKey {

        case contentBackgroundColor = "content_background_color"
        case titleColor = "title_color"
        case bodyColor = "body_color"
        case iconColor = "icon_color"
        case accentColor = "accent_color"
        case buttonColor = "button_color"
        case buttonTitleColor = "button_title_color"
        case backgroundColor = "background_color"
        case logoURL = "logo_url"
        case iconURL = "icon_url"
        case splashURL = "splash_url"
        case fontFamily = "font_family"
        case radius

    }

}
