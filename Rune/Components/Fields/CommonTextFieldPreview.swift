//
//  CommonTextFieldPreview.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 4/28/24.
//

import SwiftUI

internal struct CommonTextFieldPreview: View {
    
    @State private var text: String = ""
    @FocusState private var isFocused: Bool
    
    let placeholderColor = ThemeManager.shared.textColor(.body)
    
    var body: some View {
        
        VStack(spacing: 16) {
            
            TextField(
                "Email",
                text: self.$text,
                prompt: Text("Email").foregroundStyle(self.placeholderColor)
            )
            .focused(self.$isFocused, equals: true)
            .appTextFieldStyle(
                text: self.text,
                hint: "Email",
                icon: nil,
                isFocused: self.isFocused
            )
            .appOnTapGesture {
                self.isFocused = true
            }
            
            TextField(
                "Password",
                text: self.$text,
                prompt: Text("Password").foregroundStyle(self.placeholderColor)
            )
            .focused(self.$isFocused, equals: true)
            .appTextFieldStyle(
                text: self.text,
                hint: nil,
                icon: .image(Image(systemName: "lock.fill")),
                isFocused: self.isFocused
            )
            .appOnTapGesture {
                self.isFocused = true
            }
            
            TextField(
                "Full Name",
                text: self.$text,
                prompt: Text("Full Name").foregroundStyle(self.placeholderColor)
            )
            .focused(self.$isFocused, equals: true)
            .appTextFieldStyle(
                text: self.text,
                hint: "Full Name",
                icon: .image(Image(systemName: "person.fill")),
                isFocused: self.isFocused
            )
            .appOnTapGesture {
                self.isFocused = true
            }
            
        }
        
    }
    
}

#Preview {
    
    AppBaseView {
        
        CommonTextFieldPreview()
            .padding(.horizontal, Spacing.large.value)
        
    }
    
}
