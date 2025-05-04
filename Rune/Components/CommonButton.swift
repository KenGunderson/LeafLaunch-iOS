//
//  CustomButton.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 2/20/25.
//

import SwiftUI

struct CommonButton: View {
        
    var title: String
    var titleColor: ColorSource = Style.shared.textColor(.title)
    var icon: ImageSource?
    var backgroundStyle: ColorSource = Style.shared.accent
    var action: () -> Void
    var isEnabled: Bool
    
    init(title: String,
         titleColor: ColorSource = Style.shared.textColor(.title),
         icon: ImageSource? = nil,
         backgroundStyle: ColorSource = Style.shared.accent,
         isEnabled: Bool = true,
         action: @escaping () -> Void) {
        
        self.title = title
        self.titleColor = titleColor
        self.icon = icon
        self.backgroundStyle = backgroundStyle
        self.isEnabled = isEnabled
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
                    .appFont(with: .TITLE_T5)
                    .lineLimit(1)
                
            }
            
        }
        .buttonStyle(.commonButtonStyle(
            background: self.backgroundStyle,
            verticalPadding: .custom(12),
            horizontalPadding: .large
        ))
        .disabled(!self.isEnabled)
        
    }
    
}

#Preview {
    
    @Previewable var theme = Style.shared
    
    VStack(spacing: Style.shared.spacing(.large)) {
        
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
    
    var background: ColorSource = Style.shared.accent
    var cornerRadius: Theme.RadiusKey
    var verticalPadding: Theme.SpacingKey = .custom(12)
    var horizontalPadding: Theme.SpacingKey = .extraLarge

    func makeBody(configuration: Configuration) -> some View {
        
        configuration.label
            .padding(.horizontal, Style.shared.spacing(horizontalPadding))
            .padding(.vertical, Style.shared.spacing(verticalPadding))
            .frame(maxWidth: .infinity)
            .background(self.background.source())
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: Style.shared.radius(self.cornerRadius)))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
            .lineLimit(1)
        
        
    }
    
}

extension ButtonStyle where Self == CommonButtonStyle {
    
    static func commonButtonStyle(background: ColorSource = Style.shared.accent,
                                  cornerRadius: Theme.RadiusKey = .small,
                                  verticalPadding: Theme.SpacingKey = .small,
                                  horizontalPadding: Theme.SpacingKey = .medium) -> CommonButtonStyle {
        
        return CommonButtonStyle(
            background: background,
            cornerRadius: cornerRadius,
            verticalPadding: verticalPadding,
            horizontalPadding: horizontalPadding
        )
        
    }
    
}
