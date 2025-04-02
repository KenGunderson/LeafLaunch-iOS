//
//  AppTextField.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 4/28/24.
//

import SwiftUI

struct CommonTextFieldStyle: TextFieldStyle {
    
    var text: String
    var hint: String?
    var icon: Image?
    var isFocused: Bool
    var borderColor: AppForegroundStyle
    var foregroundColor: AppForegroundStyle
    var backgroundColor: AppBackgroundStyle
    var unselectedColor: AppForegroundStyle
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        
        let borderColor = self.borderColor.foregroundStyle()
        let foregroundColor = self.foregroundColor.foregroundStyle()
        
        ZStack(alignment: .leading) {
            
            HStack {
                
                if let icon {
                    
                    icon
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 18, height: 18)
                        .foregroundStyle(self.isFocused ? borderColor : foregroundColor)
                    
                }
                
                configuration
                
            }
            .frame(height: 50)
            .padding(.horizontal, self.icon == nil ? .medium : .small)
            .background(self.backgroundColor.backgroundStyle())
            .foregroundStyle(foregroundColor)
            .appFont(with: .title(.t5))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(self.isFocused ? borderColor : self.unselectedColor.foregroundStyle(), lineWidth: 2)
            }
            .appShadow()
            .tint(foregroundColor)
            
            if let hint {
                
                let shouldShowContainer = ((!self.text.isEmpty && self.isFocused))
                animatingContainerView(hint: hint, shouldShow: shouldShowContainer)
                
            }
            
        }
                
    }
    
    
    private func animatingContainerView(hint: String,
                                        shouldShow: Bool) -> some View {
        
        Text(self.hint ?? "")
            .font(.caption2)
            .foregroundStyle(.black)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background {
                Capsule()
                    .fill(.white)
            }
            .offset(
                x: 16,
                y: shouldShow ? -24 : 0)
            .opacity(shouldShow ? 1 : 0)
            .appShadow()
            .animation(.bouncy, value: self.text)
            .animation(.bouncy, value: self.isFocused)
        
    }
    
}

extension View {
    
    func appTextFieldStyle(text: String,
                           hint: String? = nil,
                           icon: Image? = nil,
                           isFocused: Bool,
                           borderColor: AppForegroundStyle = .color(ThemeManager.shared.accentColor()),
                           foregroundColor: AppForegroundStyle = .color(ThemeManager.shared.textColor(.body)),
                           backgroundColor: AppBackgroundStyle = .color(ThemeManager.shared.background(.secondary)),
                           unselectedColor: AppForegroundStyle = .color(ThemeManager.shared.background(.quad))) -> some View {
        
        self
            .textFieldStyle(CommonTextFieldStyle(
                text: text,
                hint: hint,
                icon: icon,
                isFocused: isFocused,
                borderColor: borderColor,
                foregroundColor: foregroundColor,
                backgroundColor: backgroundColor,
                unselectedColor: unselectedColor
            ))
        
    }
    
}
