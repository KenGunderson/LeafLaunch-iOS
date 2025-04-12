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
    var titleColor: ColorSource = Style.shared.textColor(.body)
    var placeholderColor: ColorSource = Style.shared.textColor(.title)
    var unselectedBorderColor: ColorSource = Style.shared.background(.quaternary)
    var selectedBorderColor: ColorSource = Style.shared.accent
    var backgroundStyle: ColorSource = Style.shared.background(.secondary)
    var lineLimit: ClosedRange<Int> = 5...5
    
    var body: some View {
    
        TextField(
            "Test",
            text: self.$text,
            prompt: Text(self.placehoderText).foregroundStyle(self.placeholderColor.source().opacity(0.5)),
            axis: .vertical
        )
        .lineLimit(self.lineLimit)
        .padding(16)
        .background(self.backgroundStyle.source())
        .foregroundStyle(self.titleColor.source())
        .appFont(with: .title(.t5))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(self.isFocused ? self.selectedBorderColor.source() : self.unselectedBorderColor.source(), lineWidth: 2)
        }
        .appShadow()
        .tint(self.placeholderColor.source())
        
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
                titleColor: Style.shared.textColor(.title)
            )
            .padding(.horizontal, 32)
            .focused($isFocused)
            
            CommonTextEditView(
                text: $text,
                placehoderText: "New Answer....",
                isFocused: false,
                titleColor: Style.shared.textColor(.body)
            )
            .padding(.horizontal, 32)
            .focused($isFocused)
            
        }
        
    }
    
}
