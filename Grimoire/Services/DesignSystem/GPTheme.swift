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
    
}

