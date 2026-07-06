//
//  GPTheme.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 8/15/25.
//

import SwiftUI

public extension Theme {
    
    @MainActor
    static let GLOW_PRO = Theme(
        id: "GLOW_PRO_THEME",
        isLightMode: true,
        foreground: .init(
            primary:    .color(Color(hex: "#7AD8CE")),
            secondary:  .color(Color(hex: "#9bf7ed")),
            tertiary:   .color(Color(hex: "#75CEC5")),
            quaternary: .color(Color(hex: "#75CEC5")),
            disabled: .color(Color(hex: "#DFE2E7")),
        ),
        background: .init(
            primary:    .color(Color(hex: "#F9FAFB")),
            secondary:  .color(Color(hex: "#FFFFFF")),
            tertiary:   .color(Color(hex: "#EBE6E9")),
            quaternary: .color(Color(hex: "#E6E7EB")),
            quinary:    .color(Color(hex: "#EEF0F3")),
            border:     .color(Color(hex: "#DFE2E7"))
        ),
        textColor: .init(
            title:          .color(Color(hex: "#121212")),
            titleInverted:  .color(Color(hex: "#FFFFFF")),
            body:           .color(Color(hex: "#3B4351")),
            bodyInverted:   .color(Color(hex: "#FFFFFF")),
            button:         .color(Color(hex: "#FFFFFF")),
            placeholder:    .color(Color(hex: "#98A2B3"))
        ),
        palette: .init(
            success:     .color(Color(hex: "#388E3C")),
            warning:     .color(Color(hex: "#F59E0B")),
            error:       .color(Color(hex: "#D32F2F")),
            info:        .color(Color(hex: "#2196F3")),
            link:        .color(Color(hex: "#0EA5E9")),
            highlight:   .color(Color(hex: "#7AD8CE")),
            premium:     .color(Color(hex: "#D4AF37")),
            destructive: .color(Color(hex: "#B91C1C")),
            online:      .color(Color(hex: "#22C55E")),
            offline:     .color(Color(hex: "#9CA3AF")),
            skeleton:    .color(Color(hex: "#E6E7EB"))
        ),
        spacing: .default,
        radius:  .default,
        fonts:   .sfDisplay,
        shadow:  .default,
        buttonBounceStyle: .default,
        alertStyle: .default
    )
    
    @MainActor
    static let NUDGE_LIGHT = Theme(
        id: "NUDGE_THEME_LIGHT",
        isLightMode: true,
        foreground: .init(
            primary:    .color(Color(hex: "#44C9ED")),
            secondary:  .color(Color(hex: "#26A0FF")),
            tertiary:   .color(Color(hex: "#44C9ED")),
            quaternary: .color(Color(hex: "#44C9ED")),
            disabled:   .color(Color(hex: "#DFE2E7"))
        ),
        background: .init(
            primary:    .color(Color(hex: "#F5F6FA")), // screen background
            secondary:  .color(Color(hex: "#FFFFFF")), // cards
            tertiary:   .color(Color(hex: "#EEF1F5")), // inputs / nested surfaces
            quaternary: .color(Color(hex: "#E6EAF0")), // pressed states / subtle dividers
            quinary:    .color(Color(hex: "#F9FAFC")), // elevated soft sections
            border:     .color(Color(hex: "#DDE3EA"))
        ),
        textColor: .init(
            title:          .color(Color(hex: "101828")), // requested white title
            titleInverted:  .color(Color(hex: "#FFFFFF")), // dark title for white cards / light surfaces
            body:           .color(Color(hex: "#334155")),
            bodyInverted:   .color(Color(hex: "#EAF8FD")),
            button:         .color(Color(hex: "#FFFFFF")),
            placeholder:    .color(Color(hex: "#7A8699"))
        ),
        palette: .init(
            success:     .color(Color(hex: "#388E3C")),
            warning:     .color(Color(hex: "#FFD740")),
            error:       .color(Color(hex: "#D32F2F")),
            info:        .color(Color(hex: "#2196F3")),
            link:        .color(Color(hex: "#005F8C")), // readable blue link text
            highlight:   .color(Color(hex: "#7AD8CE")),
            premium:     .color(Color(hex: "#D4AF37")),
            destructive: .color(Color(hex: "#B91C1C")),
            online:      .color(Color(hex: "#22C55E")),
            offline:     .color(Color(hex: "#9CA3AF")),
            skeleton:    .color(Color(hex: "#E6EAF0"))
        ),
        spacing: .default,
        radius:  .default,
        fonts:   .sfDisplay,
        shadow:  .default,
        buttonBounceStyle: .default,
        alertStyle: .default
    )
    
}

public extension Theme {
    
    @MainActor
    static let NUDGE_DARK = Theme(
        id: "NUDGE_THEME_DARK",
        isLightMode: false,
        foreground: .init(
            primary:    .color(Color(hex: "#0077B6")),
            secondary:  .color(Color(hex: "#0096C7")),
            tertiary:   .color(Color(hex: "#023E8A")),
            quaternary: .color(Color(hex: "#00B4D8")),
            disabled:   .color(Color(hex: "#52525B")),
        ),
        background: .init(
            primary:    .color(Color(hex: "#1C1C1E")),
            secondary:  .color(Color(hex: "#2C2C2E")),
            tertiary:   .color(Color(hex: "#3A3A3C")),
            quaternary: .color(Color(hex: "#48484A")),
            quinary:    .color(Color(hex: "#242426")),
            border:     .color(Color(hex: "#38383A"))
        ),
        textColor: .init(
            title:          .color(Color(hex: "#FFFFFF")),
            titleInverted:  .color(Color(hex: "#1C1C1E")),
            body:           .color(Color(hex: "#E4E4E7")),
            bodyInverted:   .color(Color(hex: "#1C1C1E")),
            button:         .color(Color(hex: "#FFFFFF")),
            placeholder:    .color(Color(hex: "#A1A1AA"))
        ),
        palette: .init(
            success:    .color(Color(hex: "#32D74B")),
            warning:    .color(Color(hex: "#FACC15")),
            error:      .color(Color(hex: "#FF453A")),
            info:        .color(Color(hex: "#2196F3")),
            link:        .color(Color(hex: "#0EA5E9")),
            highlight:   .color(Color(hex: "#7AD8CE")),
            premium:     .color(Color(hex: "#D4AF37")),
            destructive: .color(Color(hex: "#B91C1C")),
            online:      .color(Color(hex: "#22C55E")),
            offline:     .color(Color(hex: "#9CA3AF")),
            skeleton:    .color(Color(hex: "#E6E7EB"))
        ),
        spacing: .default,
        radius:  .default,
        fonts:   .sfDisplay,
        shadow:  .default,
        buttonBounceStyle: .default,
        alertStyle: .default
    )

}

public extension Theme {

    @MainActor
    static let MATRIX = Theme(
        id: "MATRIX",
        isLightMode: false,
        foreground: .init(
            primary:    .color(Color(hex: "#00FF88")),
            secondary:  .color(Color(hex: "#00CC6A")),
            tertiary:   .color(Color(hex: "#009950")),
            quaternary: .color(Color(hex: "#006633")),
            disabled:   .color(Color(hex: "#1A3D2B"))
        ),
        background: .init(
            primary:    .color(Color(hex: "#030D07")),
            secondary:  .color(Color(hex: "#08170E")),
            tertiary:   .color(Color(hex: "#0E2118")),
            quaternary: .color(Color(hex: "#152B20")),
            quinary:    .color(Color(hex: "#051209")),
            border:     .color(Color(hex: "#1A4030"))
        ),
        textColor: .init(
            title:          .color(Color(hex: "#B3FFDA")),
            titleInverted:  .color(Color(hex: "#030D07")),
            body:           .color(Color(hex: "#66FFAA")),
            bodyInverted:   .color(Color(hex: "#030D07")),
            button:         .color(Color(hex: "#FFFFFF")),
            placeholder:    .color(Color(hex: "#2D6B4A"))
        ),
        palette: .init(
            success:    .color(Color(hex: "#00FF88")),
            warning:    .color(Color(hex: "#CCFF33")),
            error:      .color(Color(hex: "#FF3366")),
            info:        .color(Color(hex: "#33CCFF")),
            link:        .color(Color(hex: "#33FFCC")),
            highlight:   .color(Color(hex: "#00FF88")),
            premium:     .color(Color(hex: "#FFD700")),
            destructive: .color(Color(hex: "#FF3366")),
            online:      .color(Color(hex: "#00FF88")),
            offline:     .color(Color(hex: "#3D5C4A")),
            skeleton:    .color(Color(hex: "#0E2118"))
        ),
        spacing: .default,
        radius: .default,
        fonts: .sfDisplay,
        shadow: .default,
        buttonBounceStyle: .default,
        alertStyle: .default
    )

    @MainActor
    static let NUDGE_PERIWINKLE = Theme(
        id: "NUDGE_THEME_PERIWINKLE",
        isLightMode: true,
        foreground: .init(
            primary:    .color(Color(hex: "#6B7FD4")),
            secondary:  .color(Color(hex: "#8B9FE8")),
            tertiary:   .color(Color(hex: "#A9B7EE")),
            quaternary: .color(Color(hex: "#CED5F5")),
            disabled:   .color(Color(hex: "#D8DCF0"))
        ),
        background: .init(
            primary:    .color(Color(hex: "#F6F7FD")),
            secondary:  .color(Color(hex: "#FFFFFF")),
            tertiary:   .color(Color(hex: "#EFF1FB")),
            quaternary: .color(Color(hex: "#E6E9F8")),
            quinary:    .color(Color(hex: "#F2F3FD")),
            border:     .color(Color(hex: "#CDD3EF"))
        ),
        textColor: .init(
            title:          .color(Color(hex: "#1E2559")),
            titleInverted:  .color(Color(hex: "#FFFFFF")),
            body:           .color(Color(hex: "#3D4878")),
            bodyInverted:   .color(Color(hex: "#FFFFFF")),
            button:         .color(Color(hex: "#FFFFFF")),
            placeholder:    .color(Color(hex: "#9AA3CC"))
        ),
        palette: .init(
            success:    .color(Color(hex: "#5BBFA0")),
            warning:    .color(Color(hex: "#E8A045")),
            error:      .color(Color(hex: "#D95B7A")),
            info:        .color(Color(hex: "#5B8FD9")),
            link:        .color(Color(hex: "#4A72CC")),
            highlight:   .color(Color(hex: "#9AA8E8")),
            premium:     .color(Color(hex: "#B8965C")),
            destructive: .color(Color(hex: "#C4446A")),
            online:      .color(Color(hex: "#5BBFA0")),
            offline:     .color(Color(hex: "#9AA3B8")),
            skeleton:    .color(Color(hex: "#DDE0F0"))
        ),
        spacing: .default,
        radius: .default,
        fonts: .sfDisplay,
        shadow: .default,
        buttonBounceStyle: .default,
        alertStyle: .default
    )

    // MARK: - New Themes

    @MainActor
    static let NUDGE_SUNSET = Theme(
        id: "NUDGE_THEME_SUNSET",
        isLightMode: true,
        foreground: .init(
            primary:    .color(Color(hex: "#E8622A")),
            secondary:  .color(Color(hex: "#F0914D")),
            tertiary:   .color(Color(hex: "#C4476A")),
            quaternary: .color(Color(hex: "#F5C4A0")),
            disabled:   .color(Color(hex: "#E8DDD8"))
        ),
        background: .init(
            primary:    .color(Color(hex: "#FFF9F6")),
            secondary:  .color(Color(hex: "#FFFFFF")),
            tertiary:   .color(Color(hex: "#FFF2EB")),
            quaternary: .color(Color(hex: "#FFE8DA")),
            quinary:    .color(Color(hex: "#FFF6F1")),
            border:     .color(Color(hex: "#F5D5C0"))
        ),
        textColor: .init(
            title:          .color(Color(hex: "#3D1A0A")),
            titleInverted:  .color(Color(hex: "#FFFFFF")),
            body:           .color(Color(hex: "#6B3320")),
            bodyInverted:   .color(Color(hex: "#FFFFFF")),
            button:         .color(Color(hex: "#FFFFFF")),
            placeholder:    .color(Color(hex: "#C0957A"))
        ),
        palette: .init(
            success:    .color(Color(hex: "#5BAD8A")),
            warning:    .color(Color(hex: "#F0B429")),
            error:      .color(Color(hex: "#CC3E2A")),
            info:        .color(Color(hex: "#5B8FD9")),
            link:        .color(Color(hex: "#C44A2A")),
            highlight:   .color(Color(hex: "#F5A87A")),
            premium:     .color(Color(hex: "#C9821E")),
            destructive: .color(Color(hex: "#C43020")),
            online:      .color(Color(hex: "#5BAD8A")),
            offline:     .color(Color(hex: "#B8A89A")),
            skeleton:    .color(Color(hex: "#F0DDD0"))
        ),
        spacing: .default,
        radius: .default,
        fonts: .sfDisplay,
        shadow: .default,
        buttonBounceStyle: .default,
        alertStyle: .default
    )

    @MainActor
    static let NUDGE_MIDNIGHT = Theme(
        id: "NUDGE_THEME_MIDNIGHT",
        isLightMode: false,
        foreground: .init(
            primary:    .color(Color(hex: "#A78BFA")),
            secondary:  .color(Color(hex: "#7C5FC9")),
            tertiary:   .color(Color(hex: "#5B3FA8")),
            quaternary: .color(Color(hex: "#3D2880")),
            disabled:   .color(Color(hex: "#3D3550"))
        ),
        background: .init(
            primary:    .color(Color(hex: "#0F0D1A")),
            secondary:  .color(Color(hex: "#1A1730")),
            tertiary:   .color(Color(hex: "#231F42")),
            quaternary: .color(Color(hex: "#2D2855")),
            quinary:    .color(Color(hex: "#151224")),
            border:     .color(Color(hex: "#352F60"))
        ),
        textColor: .init(
            title:          .color(Color(hex: "#EDE8FF")),
            titleInverted:  .color(Color(hex: "#0F0D1A")),
            body:           .color(Color(hex: "#C4BAF0")),
            bodyInverted:   .color(Color(hex: "#0F0D1A")),
            button:         .color(Color(hex: "#FFFFFF")),
            placeholder:    .color(Color(hex: "#6B6090"))
        ),
        palette: .init(
            success:    .color(Color(hex: "#4ADBA8")),
            warning:    .color(Color(hex: "#F5C842")),
            error:      .color(Color(hex: "#F06080")),
            info:        .color(Color(hex: "#60A5FA")),
            link:        .color(Color(hex: "#A78BFA")),
            highlight:   .color(Color(hex: "#C4A8FF")),
            premium:     .color(Color(hex: "#FFD700")),
            destructive: .color(Color(hex: "#F06080")),
            online:      .color(Color(hex: "#4ADBA8")),
            offline:     .color(Color(hex: "#5A5575")),
            skeleton:    .color(Color(hex: "#231F42"))
        ),
        spacing: .default,
        radius: .default,
        fonts: .sfDisplay,
        shadow: .default,
        buttonBounceStyle: .default,
        alertStyle: .default
    )

    @MainActor
    static let NUDGE_FOREST = Theme(
        id: "NUDGE_THEME_FOREST",
        isLightMode: false,
        foreground: .init(
            primary:    .color(Color(hex: "#6BBF8A")),
            secondary:  .color(Color(hex: "#4A9E6A")),
            tertiary:   .color(Color(hex: "#2D7A4A")),
            quaternary: .color(Color(hex: "#1A5535")),
            disabled:   .color(Color(hex: "#2D3D33"))
        ),
        background: .init(
            primary:    .color(Color(hex: "#0C130F")),
            secondary:  .color(Color(hex: "#151E17")),
            tertiary:   .color(Color(hex: "#1E2B20")),
            quaternary: .color(Color(hex: "#27382A")),
            quinary:    .color(Color(hex: "#101812")),
            border:     .color(Color(hex: "#2D4030"))
        ),
        textColor: .init(
            title:          .color(Color(hex: "#D4EDDA")),
            titleInverted:  .color(Color(hex: "#0C130F")),
            body:           .color(Color(hex: "#A8D4B4")),
            bodyInverted:   .color(Color(hex: "#0C130F")),
            button:         .color(Color(hex: "#FFFFFF")),
            placeholder:    .color(Color(hex: "#4A6B52"))
        ),
        palette: .init(
            success:    .color(Color(hex: "#6BBF8A")),
            warning:    .color(Color(hex: "#D4A847")),
            error:      .color(Color(hex: "#C45B6A")),
            info:        .color(Color(hex: "#5BA8C4")),
            link:        .color(Color(hex: "#8BCFAA")),
            highlight:   .color(Color(hex: "#A8E0BC")),
            premium:     .color(Color(hex: "#D4A847")),
            destructive: .color(Color(hex: "#C45B6A")),
            online:      .color(Color(hex: "#6BBF8A")),
            offline:     .color(Color(hex: "#4A5C4D")),
            skeleton:    .color(Color(hex: "#1E2B20"))
        ),
        spacing: .default,
        radius: .default,
        fonts: .sfDisplay,
        shadow: .default,
        buttonBounceStyle: .default,
        alertStyle: .default
    )

    @MainActor
    static let TEAL_CYAN_LIGHT = Theme(
        id: "TEAL_CYAN_LIGHT",
        isLightMode: true,
        foreground: .init(
            primary:    .color(Color(hex: "#0ABFBC")),
            secondary:  .color(Color(hex: "#2DD4CC")),
            tertiary:   .color(Color(hex: "#57E0D5")),
            quaternary: .color(Color(hex: "#A8F0EB")),
            disabled:   .color(Color(hex: "#D0EEED"))
        ),
        background: .init(
            primary:    .color(Color(hex: "#F4FDFB")),
            secondary:  .color(Color(hex: "#FFFFFF")),
            tertiary:   .color(Color(hex: "#ECF9F7")),
            quaternary: .color(Color(hex: "#E0F5F3")),
            quinary:    .color(Color(hex: "#F0FAFA")),
            border:     .color(Color(hex: "#C0E8E5"))
        ),
        textColor: .init(
            title:          .color(Color(hex: "#0A3535")),
            titleInverted:  .color(Color(hex: "#FFFFFF")),
            body:           .color(Color(hex: "#275858")),
            bodyInverted:   .color(Color(hex: "#FFFFFF")),
            button:         .color(Color(hex: "#FFFFFF")),
            placeholder:    .color(Color(hex: "#7ABFBC"))
        ),
        palette: .init(
            success:    .color(Color(hex: "#0ABFBC")),
            warning:    .color(Color(hex: "#E8A042")),
            error:      .color(Color(hex: "#D95B6A")),
            info:        .color(Color(hex: "#3B8FD9")),
            link:        .color(Color(hex: "#0A8F8C")),
            highlight:   .color(Color(hex: "#57E0D5")),
            premium:     .color(Color(hex: "#B8A030")),
            destructive: .color(Color(hex: "#C44455")),
            online:      .color(Color(hex: "#0ABFBC")),
            offline:     .color(Color(hex: "#90B0AE")),
            skeleton:    .color(Color(hex: "#D8EFED"))
        ),
        spacing: .default,
        radius: .default,
        fonts: .sfDisplay,
        shadow: .default,
        buttonBounceStyle: .default,
        alertStyle: .default
    )

    // Deep navy with electric gold accents — rich, premium dark
    @MainActor
    static let NUDGE_NAVY = Theme(
        id: "NUDGE_THEME_NAVY",
        isLightMode: false,
        foreground: .init(
            primary:    .color(Color(hex: "#F0C040")),
            secondary:  .color(Color(hex: "#D4A820")),
            tertiary:   .color(Color(hex: "#B08010")),
            quaternary: .color(Color(hex: "#8A6008")),
            disabled:   .color(Color(hex: "#2D3550"))
        ),
        background: .init(
            primary:    .color(Color(hex: "#0A0F1E")),
            secondary:  .color(Color(hex: "#131929")),
            tertiary:   .color(Color(hex: "#1C2438")),
            quaternary: .color(Color(hex: "#253048")),
            quinary:    .color(Color(hex: "#0E1524")),
            border:     .color(Color(hex: "#2A3A55"))
        ),
        textColor: .init(
            title:          .color(Color(hex: "#EDF2FF")),
            titleInverted:  .color(Color(hex: "#0A0F1E")),
            body:           .color(Color(hex: "#A8B8D8")),
            bodyInverted:   .color(Color(hex: "#0A0F1E")),
            button:         .color(Color(hex: "#FFFFFF")),
            placeholder:    .color(Color(hex: "#405070"))
        ),
        palette: .init(
            success:    .color(Color(hex: "#3DD68C")),
            warning:    .color(Color(hex: "#F0C040")),
            error:      .color(Color(hex: "#F06070")),
            info:        .color(Color(hex: "#60A0FA")),
            link:        .color(Color(hex: "#80C0FF")),
            highlight:   .color(Color(hex: "#F0D080")),
            premium:     .color(Color(hex: "#F0C040")),
            destructive: .color(Color(hex: "#F06070")),
            online:      .color(Color(hex: "#3DD68C")),
            offline:     .color(Color(hex: "#405070")),
            skeleton:    .color(Color(hex: "#1C2438"))
        ),
        spacing: .default,
        radius: .default,
        fonts: .sfDisplay,
        shadow: .default,
        buttonBounceStyle: .default,
        alertStyle: .default
    )

    // Warm cream and terracotta — earthy, cozy, editorial
    @MainActor
    static let NUDGE_EARTH = Theme(
        id: "NUDGE_THEME_EARTH",
        isLightMode: true,
        foreground: .init(
            primary:    .color(Color(hex: "#C0593A")),
            secondary:  .color(Color(hex: "#D97850")),
            tertiary:   .color(Color(hex: "#A84828")),
            quaternary: .color(Color(hex: "#EDB898")),
            disabled:   .color(Color(hex: "#E0D5CC"))
        ),
        background: .init(
            primary:    .color(Color(hex: "#FAF6F1")),
            secondary:  .color(Color(hex: "#FFFFFF")),
            tertiary:   .color(Color(hex: "#F4EDE5")),
            quaternary: .color(Color(hex: "#EDE0D4")),
            quinary:    .color(Color(hex: "#F8F3EE")),
            border:     .color(Color(hex: "#DECCBC"))
        ),
        textColor: .init(
            title:          .color(Color(hex: "#2C1810")),
            titleInverted:  .color(Color(hex: "#FFFFFF")),
            body:           .color(Color(hex: "#5C3828")),
            bodyInverted:   .color(Color(hex: "#FFFFFF")),
            button:         .color(Color(hex: "#FFFFFF")),
            placeholder:    .color(Color(hex: "#B89888"))
        ),
        palette: .init(
            success:    .color(Color(hex: "#5A9A6A")),
            warning:    .color(Color(hex: "#D4920A")),
            error:      .color(Color(hex: "#B83828")),
            info:        .color(Color(hex: "#4A78B8")),
            link:        .color(Color(hex: "#A84828")),
            highlight:   .color(Color(hex: "#D4A070")),
            premium:     .color(Color(hex: "#B89020")),
            destructive: .color(Color(hex: "#B03020")),
            online:      .color(Color(hex: "#5A9A6A")),
            offline:     .color(Color(hex: "#B09888")),
            skeleton:    .color(Color(hex: "#EDE0D4"))
        ),
        spacing: .default,
        radius: .default,
        fonts: .sfDisplay,
        shadow: .default,
        buttonBounceStyle: .default,
        alertStyle: .default
    )

    // Cool slate and arctic blue — minimal, professional, crisp
    @MainActor
    static let NUDGE_ARCTIC = Theme(
        id: "NUDGE_THEME_ARCTIC",
        isLightMode: true,
        foreground: .init(
            primary:    .color(Color(hex: "#2E7CF6")),
            secondary:  .color(Color(hex: "#5595F8")),
            tertiary:   .color(Color(hex: "#84B4FA")),
            quaternary: .color(Color(hex: "#C0D8FD")),
            disabled:   .color(Color(hex: "#D4DFF0"))
        ),
        background: .init(
            primary:    .color(Color(hex: "#F5F8FF")),
            secondary:  .color(Color(hex: "#FFFFFF")),
            tertiary:   .color(Color(hex: "#EBF1FD")),
            quaternary: .color(Color(hex: "#DDE8FC")),
            quinary:    .color(Color(hex: "#F0F5FF")),
            border:     .color(Color(hex: "#C8D8F5"))
        ),
        textColor: .init(
            title:          .color(Color(hex: "#0A1A40")),
            titleInverted:  .color(Color(hex: "#FFFFFF")),
            body:           .color(Color(hex: "#2A3E6A")),
            bodyInverted:   .color(Color(hex: "#FFFFFF")),
            button:         .color(Color(hex: "#FFFFFF")),
            placeholder:    .color(Color(hex: "#8A9EC8"))
        ),
        palette: .init(
            success:    .color(Color(hex: "#25A870")),
            warning:    .color(Color(hex: "#E8A020")),
            error:      .color(Color(hex: "#D84040")),
            info:        .color(Color(hex: "#2E7CF6")),
            link:        .color(Color(hex: "#1A60D0")),
            highlight:   .color(Color(hex: "#84D4F8")),
            premium:     .color(Color(hex: "#A080D0")),
            destructive: .color(Color(hex: "#C83030")),
            online:      .color(Color(hex: "#25A870")),
            offline:     .color(Color(hex: "#8A9EB8")),
            skeleton:    .color(Color(hex: "#DDE8FC"))
        ),
        spacing: .default,
        radius: .default,
        fonts: .sfDisplay,
        shadow: .default,
        buttonBounceStyle: .default,
        alertStyle: .default
    )

    // Deep charcoal with rose gold — dark, elegant, modern
    @MainActor
    static let NUDGE_ROSE_GOLD = Theme(
        id: "NUDGE_THEME_ROSE_GOLD",
        isLightMode: false,
        foreground: .init(
            primary:    .color(Color(hex: "#E8A0A0")),
            secondary:  .color(Color(hex: "#C87878")),
            tertiary:   .color(Color(hex: "#A85858")),
            quaternary: .color(Color(hex: "#804040")),
            disabled:   .color(Color(hex: "#3A3030"))
        ),
        background: .init(
            primary:    .color(Color(hex: "#141010")),
            secondary:  .color(Color(hex: "#201818")),
            tertiary:   .color(Color(hex: "#2C2020")),
            quaternary: .color(Color(hex: "#382828")),
            quinary:    .color(Color(hex: "#181414")),
            border:     .color(Color(hex: "#402E2E"))
        ),
        textColor: .init(
            title:          .color(Color(hex: "#F5E8E8")),
            titleInverted:  .color(Color(hex: "#141010")),
            body:           .color(Color(hex: "#D0B0B0")),
            bodyInverted:   .color(Color(hex: "#141010")),
            button:         .color(Color(hex: "#FFFFFF")),
            placeholder:    .color(Color(hex: "#705050"))
        ),
        palette: .init(
            success:    .color(Color(hex: "#60C090")),
            warning:    .color(Color(hex: "#E8C060")),
            error:      .color(Color(hex: "#E06060")),
            info:        .color(Color(hex: "#6090E0")),
            link:        .color(Color(hex: "#E8A0A0")),
            highlight:   .color(Color(hex: "#F0C0C0")),
            premium:     .color(Color(hex: "#E8C080")),
            destructive: .color(Color(hex: "#E06060")),
            online:      .color(Color(hex: "#60C090")),
            offline:     .color(Color(hex: "#605050")),
            skeleton:    .color(Color(hex: "#2C2020"))
        ),
        spacing: .default,
        radius: .default,
        fonts: .sfDisplay,
        shadow: .default,
        buttonBounceStyle: .default,
        alertStyle: .default
    )

    // Soft sage and warm linen — calm, natural, light
    @MainActor
    static let NUDGE_SAGE = Theme(
        id: "NUDGE_THEME_SAGE",
        isLightMode: true,
        foreground: .init(
            primary:    .color(Color(hex: "#5A8A68")),
            secondary:  .color(Color(hex: "#78A882")),
            tertiary:   .color(Color(hex: "#9AC0A0")),
            quaternary: .color(Color(hex: "#C0DAC4")),
            disabled:   .color(Color(hex: "#D4E4D8"))
        ),
        background: .init(
            primary:    .color(Color(hex: "#F6FAF6")),
            secondary:  .color(Color(hex: "#FFFFFF")),
            tertiary:   .color(Color(hex: "#EDF5EE")),
            quaternary: .color(Color(hex: "#E0EDE2")),
            quinary:    .color(Color(hex: "#F2F8F3")),
            border:     .color(Color(hex: "#C8DCC8"))
        ),
        textColor: .init(
            title:          .color(Color(hex: "#1A2E1E")),
            titleInverted:  .color(Color(hex: "#FFFFFF")),
            body:           .color(Color(hex: "#385840")),
            bodyInverted:   .color(Color(hex: "#FFFFFF")),
            button:         .color(Color(hex: "#FFFFFF")),
            placeholder:    .color(Color(hex: "#8AB090"))
        ),
        palette: .init(
            success:    .color(Color(hex: "#5A8A68")),
            warning:    .color(Color(hex: "#C89038")),
            error:      .color(Color(hex: "#C05858")),
            info:        .color(Color(hex: "#4A7AB0")),
            link:        .color(Color(hex: "#3A6A50")),
            highlight:   .color(Color(hex: "#A0C8A8")),
            premium:     .color(Color(hex: "#B09040")),
            destructive: .color(Color(hex: "#B84848")),
            online:      .color(Color(hex: "#5A8A68")),
            offline:     .color(Color(hex: "#98B098")),
            skeleton:    .color(Color(hex: "#E0EDE2"))
        ),
        spacing: .default,
        radius: .default,
        fonts: .sfDisplay,
        shadow: .default,
        buttonBounceStyle: .default,
        alertStyle: .default
    )

    // True black with neon cyan — cyberpunk, high energy, dark
    @MainActor
    static let NUDGE_NEON = Theme(
        id: "NUDGE_THEME_NEON",
        isLightMode: false,
        foreground: .init(
            primary:    .color(Color(hex: "#00E5FF")),
            secondary:  .color(Color(hex: "#00B8D4")),
            tertiary:   .color(Color(hex: "#0090A8")),
            quaternary: .color(Color(hex: "#006878")),
            disabled:   .color(Color(hex: "#1A3038"))
        ),
        background: .init(
            primary:    .color(Color(hex: "#030508")),
            secondary:  .color(Color(hex: "#080C12")),
            tertiary:   .color(Color(hex: "#0E141E")),
            quaternary: .color(Color(hex: "#141C28")),
            quinary:    .color(Color(hex: "#05080E")),
            border:     .color(Color(hex: "#183048"))
        ),
        textColor: .init(
            title:          .color(Color(hex: "#C8F8FF")),
            titleInverted:  .color(Color(hex: "#030508")),
            body:           .color(Color(hex: "#70D8F0")),
            bodyInverted:   .color(Color(hex: "#030508")),
            button:         .color(Color(hex: "#FFFFFF")),
            placeholder:    .color(Color(hex: "#205870"))
        ),
        palette: .init(
            success:    .color(Color(hex: "#00FF88")),
            warning:    .color(Color(hex: "#FFE000")),
            error:      .color(Color(hex: "#FF2060")),
            info:        .color(Color(hex: "#00E5FF")),
            link:        .color(Color(hex: "#40F0FF")),
            highlight:   .color(Color(hex: "#00E5FF")),
            premium:     .color(Color(hex: "#FFD700")),
            destructive: .color(Color(hex: "#FF2060")),
            online:      .color(Color(hex: "#00FF88")),
            offline:     .color(Color(hex: "#204050")),
            skeleton:    .color(Color(hex: "#0E141E"))
        ),
        spacing: .default,
        radius: .default,
        fonts: .sfDisplay,
        shadow: .default,
        buttonBounceStyle: .default,
        alertStyle: .default
    )

    @MainActor
    static let NUDGE_CANDY = Theme(
        id: "NUDGE_THEME_CANDY",
        isLightMode: true,
        foreground: .init(
            primary:    .color(Color(hex: "#FF3CAC")),
            secondary:  .color(Color(hex: "#FF79C6")),
            tertiary:   .color(Color(hex: "#784BA0")),
            quaternary: .color(Color(hex: "#FFB3DE")),
            disabled:   .color(Color(hex: "#E0D5E8"))
        ),
        background: .init(
            primary:    .color(Color(hex: "#FFF5FC")),
            secondary:  .color(Color(hex: "#FFFFFF")),
            tertiary:   .color(Color(hex: "#FDEEF9")),
            quaternary: .color(Color(hex: "#FAE5F5")),
            quinary:    .color(Color(hex: "#FEF2FB")),
            border:     .color(Color(hex: "#F5C8EA"))
        ),
        textColor: .init(
            title:          .color(Color(hex: "#3D0A2E")),
            titleInverted:  .color(Color(hex: "#FFFFFF")),
            body:           .color(Color(hex: "#6B2458")),
            bodyInverted:   .color(Color(hex: "#FFFFFF")),
            button:         .color(Color(hex: "#FFFFFF")),
            placeholder:    .color(Color(hex: "#C890B8"))
        ),
        palette: .init(
            success:    .color(Color(hex: "#52D68A")),
            warning:    .color(Color(hex: "#FFB347")),
            error:      .color(Color(hex: "#FF3366")),
            info:        .color(Color(hex: "#7B68EE")),
            link:        .color(Color(hex: "#9B50CC")),
            highlight:   .color(Color(hex: "#FF79C6")),
            premium:     .color(Color(hex: "#FFD700")),
            destructive: .color(Color(hex: "#E0205A")),
            online:      .color(Color(hex: "#52D68A")),
            offline:     .color(Color(hex: "#B8A0C0")),
            skeleton:    .color(Color(hex: "#F5D5EE"))
        ),
        spacing: .default,
        radius: .default,
        fonts: .sfDisplay,
        shadow: .default,
        buttonBounceStyle: .default,
        alertStyle: .default
    )
    
}

