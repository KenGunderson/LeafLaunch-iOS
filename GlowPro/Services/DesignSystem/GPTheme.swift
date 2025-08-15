//
//  GPTheme.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/15/25.
//

import SwiftUI

public extension Theme {
    
    static let GLOW_PRO = Theme(
        id: "GLOW_PRO_THEME",
        foreground: .init(
            primary:    .color(Color(hex: "#7AD8CE")),
            secondary:  .color(Color(hex: "#9bf7ed")),
            tertiary:   .color(Color(hex: "#75CEC5")),
            quaternary: .color(Color(hex: "#75CEC5"))
        ),
        background: .init(
            primary:    .color(Color(hex: "#F9FAFB")),
            secondary:  .color(Color(hex: "#FFFFFF")),
            tertiary:   .color(Color(hex: "#EBE6E9")),
            quaternary: .color(Color(hex: "#E6E7EB")),
            error:      .color(Color(hex: "#D32F2F")),
            success:    .color(Color(hex: "#388E3C")),
            border:     .color(Color(hex: "#EDEEF0"))
        ),
        textColor: .init(
            title:          .color(Color(hex: "#121212")),
            titleInverted:  .color(Color(hex: "#FFFFFF")),
            body:           .color(Color(hex: "#3B4351")),
            bodyInverted:   .color(Color(hex: "#FFFFFF")),
            button:         .color(Color(hex: "#FFFFFF")),
            placeholder:    .color(Color(hex: "#98A2B3"))
        ),
        spacing: .default,
        radius:  .default,
        fonts:   .sfDisplay,
        shadow:  .default,
        buttonBounceStyle: .default
    )
    
}

