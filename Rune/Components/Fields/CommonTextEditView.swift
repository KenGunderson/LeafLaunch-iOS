//
//  TextEditView.swift
//  Rune
//
//  Created by Sako Hovaguimian on 4/3/25.
//


import SwiftUI

struct CommonTextEditView: View {
    
    @Binding var text: String
    var placehoderText: String
    var isFocused: Bool
    var titleColor: AppForegroundStyle = .color(ThemeManager.shared.textColor(.body))
    var placeholderColor: AppForegroundStyle = .color(ThemeManager.shared.textColor(.title).opacity(0.5))
    var unselectedBorderColor: AppBackgroundStyle = .color(ThemeManager.shared.background(.quad))
    var selectedBorderColor: AppForegroundStyle = .color(ThemeManager.shared.accentColor())
    var backgroundStyle: AppBackgroundStyle = .color(ThemeManager.shared.background(.secondary))
    var lineLimit: ClosedRange<Int> = 5...5
    
    var body: some View {
    
        TextField(
            "Test",
            text: self.$text,
            prompt: Text(self.placehoderText).foregroundStyle(self.placeholderColor.foregroundStyle()),
            axis: .vertical
        )
        .lineLimit(self.lineLimit)
        .padding(16)
        .background(self.backgroundStyle.backgroundStyle())
        .foregroundStyle(self.titleColor.foregroundStyle())
        .appFont(with: .title(.t5))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(self.isFocused ? self.selectedBorderColor.foregroundStyle() : self.unselectedBorderColor.backgroundStyle(), lineWidth: 2)
        }
        .appShadow()
        .tint(self.placeholderColor.foregroundStyle())
        
    }
    
}

#Preview {
    
    @Previewable @State var text: String = ""
    @FocusState var isFocused: Bool
    
    AppBaseView {
        
        VStack {
            
            CommonTextEditView(
                text: $text,
                placehoderText: "Answer...",
                isFocused: false,
                titleColor: .color(ThemeManager.shared.textColor(.title))
            )
            .padding(.horizontal, 32)
            .focused($isFocused)
            
            CommonTextEditView(
                text: $text,
                placehoderText: "New Answer....",
                isFocused: false,
                titleColor: .color(ThemeManager.shared.textColor(.body))
            )
            .padding(.horizontal, 32)
            .focused($isFocused)
            
        }
        
    }
    
}
