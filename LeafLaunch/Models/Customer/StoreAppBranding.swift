import Foundation

nonisolated struct StoreAppBranding: Codable, Equatable, Sendable {

    let primaryColor: String?
    let accentColor: String?
    let backgroundColor: String?
    let textColor: String?
    let logoObjectKey: String?
    let iconObjectKey: String?
    let splashObjectKey: String?
    let fontFamily: String?

    init(primaryColor: String? = nil,
         accentColor: String? = nil,
         backgroundColor: String? = nil,
         textColor: String? = nil,
         logoObjectKey: String? = nil,
         iconObjectKey: String? = nil,
         splashObjectKey: String? = nil,
         fontFamily: String? = nil) {

        self.primaryColor = primaryColor
        self.accentColor = accentColor
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.logoObjectKey = logoObjectKey
        self.iconObjectKey = iconObjectKey
        self.splashObjectKey = splashObjectKey
        self.fontFamily = fontFamily

    }

    private enum CodingKeys: String, CodingKey {

        case primaryColor = "primary_color"
        case accentColor = "accent_color"
        case backgroundColor = "background_color"
        case textColor = "text_color"
        case logoObjectKey = "logo_object_key"
        case iconObjectKey = "icon_object_key"
        case splashObjectKey = "splash_object_key"
        case fontFamily = "font_family"

    }

}
