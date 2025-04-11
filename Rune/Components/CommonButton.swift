//
//  CustomButton.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 2/20/25.
//

import SwiftUI

struct CommonButton: View {
        
    var title: String
    var titleColor: ColorSource = DesignSystem.shared.textColor(.title)
    var icon: ImageSource?
    var backgroundStyle: ColorSource = DesignSystem.shared.accent
    var action: () -> Void
    
    init(title: String,
         titleColor: ColorSource = DesignSystem.shared.textColor(.title),
         icon: ImageSource? = nil,
         backgroundStyle: ColorSource = DesignSystem.shared.accent,
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
                    
                    icon.view()
                        .fixedSize(horizontal: true, vertical: true)
                    
                }
                
                Text(self.title)
                    .foregroundStyle(self.titleColor.source())
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
    
    @Previewable var theme = DesignSystem.shared
    
    VStack(spacing: DesignSystem.shared.spacing(.large)) {
        
        CommonButton(title: "Common Button", icon: .systemImage("person.fill")) {}
        .padding(.horizontal, .custom(64))
        
        Image(systemName: "person.fill")
            .fontWeight(.bold)
            .padding(.medium)
            .foregroundStyle(.white)
            .background(theme.accent.source())
            .clipShape(.circle)
            .asButton {}
        
        CircularIconView(
            foregroundColor: .color(.cyan),
            backgroundColor: .color(.cyan.opacity(0.3)),
            size: 50,
            imageSource: .systemImage("person.fill")
        )
        
    }
    
}

struct CommonButtonStyle: ButtonStyle {
    
    var background: ColorSource = DesignSystem.shared.accent
    var cornerRadius: CornerRadius
    var verticalPadding: CustomTheme.SpacingKey = .custom(12)
    var horizontalPadding: CustomTheme.SpacingKey = .extraLarge

    func makeBody(configuration: Configuration) -> some View {
        
        configuration.label
            .padding(.horizontal, DesignSystem.shared.spacing(horizontalPadding))
            .padding(.vertical, DesignSystem.shared.spacing(verticalPadding))
            .frame(maxWidth: .infinity)
            .background(self.background.source())
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: self.cornerRadius.value))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
            .lineLimit(1)
        
        
    }
    
}

extension ButtonStyle where Self == CommonButtonStyle {
    
    static func commonButtonStyle(background: ColorSource = DesignSystem.shared.accent,
                                  cornerRadius: CornerRadius = .small,
                                  verticalPadding: CustomTheme.SpacingKey = .small,
                                  horizontalPadding: CustomTheme.SpacingKey = .medium) -> CommonButtonStyle {
        
        return CommonButtonStyle(
            background: background,
            cornerRadius: cornerRadius,
            verticalPadding: verticalPadding,
            horizontalPadding: horizontalPadding
        )
        
    }
    
}
