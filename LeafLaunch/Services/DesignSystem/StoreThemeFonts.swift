//
//  StoreThemeFonts.swift
//  LeafLaunch
//

import UIKit

extension Theme.Fonts {

    static func storeBranding(familyName: StoreAppFontFamily?, fallback: Theme.Fonts) -> Theme.Fonts {

        guard let familyName, familyName != .system,
              !UIFont.fontNames(forFamilyName: familyName.rawValue).isEmpty else { return fallback }

        func font(_ base: UIFont) -> UIFont {
            UIFont(descriptor: base.fontDescriptor.withFamily(familyName.rawValue), size: base.pointSize)
        }

        return Theme.Fonts(
            BILLBOARD_1: font(fallback.BILLBOARD_1),
            BILLBOARD_2: font(fallback.BILLBOARD_2),
            BILLBOARD_3: font(fallback.BILLBOARD_3),
            BILLBOARD_4: font(fallback.BILLBOARD_4),
            BILLBOARD_5: font(fallback.BILLBOARD_5),
            HEADER_5: font(fallback.HEADER_5),
            HEADER_4: font(fallback.HEADER_4),
            HEADER_3: font(fallback.HEADER_3),
            HEADER_2: font(fallback.HEADER_2),
            HEADER_1: font(fallback.HEADER_1),
            TITLE_1: font(fallback.TITLE_1),
            TITLE_2: font(fallback.TITLE_2),
            TITLE_3: font(fallback.TITLE_3),
            TITLE_4: font(fallback.TITLE_4),
            TITLE_5: font(fallback.TITLE_5),
            TITLE_6: font(fallback.TITLE_6),
            TITLE_7: font(fallback.TITLE_7),
            SUBTITLE_1: font(fallback.SUBTITLE_1),
            SUBTITLE_2: font(fallback.SUBTITLE_2),
            SUBTITLE_3: font(fallback.SUBTITLE_3),
            SUBTITLE_4: font(fallback.SUBTITLE_4),
            SUBTITLE_5: font(fallback.SUBTITLE_5),
            BODY_1: font(fallback.BODY_1),
            BODY_2: font(fallback.BODY_2),
            BODY_3: font(fallback.BODY_3),
            BODY_4: font(fallback.BODY_4),
            BODY_5: font(fallback.BODY_5),
            NOTE_1: font(fallback.NOTE_1),
            NOTE_2: font(fallback.NOTE_2),
            NOTE_3: font(fallback.NOTE_3),
            NOTE_4: font(fallback.NOTE_4),
            NOTE_5: font(fallback.NOTE_5)
        )

    }

}
