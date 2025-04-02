//
//  CustomButton.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 2/20/25.
//

import SwiftUI

struct CommonButton: View {
        
    var title: String
    var titleColor: AppForegroundStyle = .color(ThemeManager.shared.textColor(.title))
    var icon: Image?
    var backgroundStyle: AppBackgroundStyle = .color(ThemeManager.shared.accentColor())
    var action: () -> Void
    
    init(title: String,
         titleColor: AppForegroundStyle = .color(ThemeManager.shared.textColor(.title)),
         icon: Image? = nil,
         backgroundStyle: AppBackgroundStyle = .color(ThemeManager.shared.accentColor()),
         action: @escaping () -> Void) {
        
        self.title = title
        self.titleColor = titleColor
        self.icon = icon
        self.backgroundStyle = backgroundStyle
        self.action = action
        
    }
    
    var body: some View {
                
        Button {
            
            self.action()
            
        } label: {
            
            HStack {
                
                if let icon {
                    icon
                }
                
                Text(self.title)
                    .foregroundStyle(self.titleColor.foregroundStyle())
                    .appFont(with: .title(.t5))
                    .lineLimit(1)
                
            }
            
        }
        .buttonStyle(.commonButtonStyle(
            background: self.backgroundStyle,
            verticalPadding: .custom(12),
            horizontalPadding: .large
        ))
        
    }
    
}

#Preview {
    
    @Previewable var theme = ThemeManager.shared
    
    VStack(spacing: Spacing.large.value) {
        
        CommonButton(title: "Common Button", action: {
            
            theme.updateTheme(.BLUE)
            
        })
        .padding(.horizontal, .custom(64))
        
        Image(systemName: "person.fill")
            .fontWeight(.bold)
            .padding(.medium)
            .foregroundStyle(.white)
            .background(theme.accentColor())
            .clipShape(.circle)
            .asButton {
                
                theme.updateTheme(.GOLD_NAVY)
                
            }
        
        CircularIconView(
            foregroundColor: .color(.cyan),
            backgroundColor: .color(.cyan.opacity(0.3)),
            size: 50,
            systemImage: "person.fill"
        )
        
    }
    
}

struct CommonButtonStyle: ButtonStyle {
    
    var background: AppBackgroundStyle = .color(ThemeManager.shared.accentColor())
    var cornerRadius: CornerRadius
    var verticalPadding: Spacing = .custom(12)
    var horizontalPadding: Spacing = .xLarge

    func makeBody(configuration: Configuration) -> some View {
        
        configuration.label
            .padding(.horizontal, self.horizontalPadding.value)
            .padding(.vertical, self.verticalPadding.value)
            .frame(maxWidth: .infinity)
            .background(self.background.backgroundStyle())
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: self.cornerRadius.value))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
            .lineLimit(1)
        
        
    }
    
}

extension ButtonStyle where Self == CommonButtonStyle {
    
    static func commonButtonStyle(background: AppBackgroundStyle = .color(ThemeManager.shared.accentColor()),
                                  cornerRadius: CornerRadius = .small,
                                  verticalPadding: Spacing = .small,
                                  horizontalPadding: Spacing = .medium) -> CommonButtonStyle {
        
        return CommonButtonStyle(
            background: background,
            cornerRadius: cornerRadius,
            verticalPadding: verticalPadding,
            horizontalPadding: horizontalPadding
        )
        
    }
    
}
