//
//  LeafLaunchFonts.swift
//  LeafLaunch
//

import SwiftUI

// Native system sans substitutes for the web's IBM Plex Sans without bundling fonts.
// Sizes follow theme.css (14, 16, 18, 20, 24, 28, 32, 40, 52, 64, 80).
// Rune's font contract does not carry CSS line height or letter spacing.
extension Theme.Fonts {

    static var leafLaunch: Theme.Fonts {

        Theme.Fonts(
            BILLBOARD_1: .systemFont(ofSize: 32, weight: .semibold),
            BILLBOARD_2: .systemFont(ofSize: 40, weight: .semibold),
            BILLBOARD_3: .systemFont(ofSize: 52, weight: .semibold),
            BILLBOARD_4: .systemFont(ofSize: 64, weight: .semibold),
            BILLBOARD_5: .systemFont(ofSize: 80, weight: .semibold),

            HEADER_5: .systemFont(ofSize: 32, weight: .semibold),
            HEADER_4: .systemFont(ofSize: 28, weight: .semibold),
            HEADER_3: .systemFont(ofSize: 24, weight: .semibold),
            HEADER_2: .systemFont(ofSize: 20, weight: .semibold),
            HEADER_1: .systemFont(ofSize: 18, weight: .semibold),

            TITLE_1: .systemFont(ofSize: 14, weight: .medium),
            TITLE_2: .systemFont(ofSize: 14, weight: .semibold),
            TITLE_3: .systemFont(ofSize: 16, weight: .semibold),
            TITLE_4: .systemFont(ofSize: 18, weight: .semibold),
            TITLE_5: .systemFont(ofSize: 20, weight: .semibold),
            TITLE_6: .systemFont(ofSize: 24, weight: .semibold),
            TITLE_7: .systemFont(ofSize: 28, weight: .semibold),

            SUBTITLE_1: .systemFont(ofSize: 14, weight: .medium),
            SUBTITLE_2: .systemFont(ofSize: 16, weight: .medium),
            SUBTITLE_3: .systemFont(ofSize: 18, weight: .medium),
            SUBTITLE_4: .systemFont(ofSize: 20, weight: .medium),
            SUBTITLE_5: .systemFont(ofSize: 24, weight: .medium),

            BODY_1: .systemFont(ofSize: 14, weight: .regular),
            BODY_2: .systemFont(ofSize: 16, weight: .regular),
            BODY_3: .systemFont(ofSize: 18, weight: .regular),
            BODY_4: .systemFont(ofSize: 20, weight: .regular),
            BODY_5: .systemFont(ofSize: 24, weight: .regular),

            NOTE_1: .systemFont(ofSize: 14, weight: .regular),
            NOTE_2: .systemFont(ofSize: 14, weight: .regular),
            NOTE_3: .systemFont(ofSize: 14, weight: .regular),
            NOTE_4: .systemFont(ofSize: 16, weight: .regular),
            NOTE_5: .systemFont(ofSize: 18, weight: .regular)
        )

    }

}
