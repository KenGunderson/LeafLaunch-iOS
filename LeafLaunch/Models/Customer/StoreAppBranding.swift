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
    let logoObjectKey: String?
    let iconObjectKey: String?
    let splashObjectKey: String?
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
         logoObjectKey: String? = nil,
         iconObjectKey: String? = nil,
         splashObjectKey: String? = nil,
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
        self.logoObjectKey = logoObjectKey
        self.iconObjectKey = iconObjectKey
        self.splashObjectKey = splashObjectKey
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
        case logoObjectKey = "logo_object_key"
        case iconObjectKey = "icon_object_key"
        case splashObjectKey = "splash_object_key"
        case fontFamily = "font_family"
        case radius

    }

}
