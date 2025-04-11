//
//  CodeInputView.swift
//  Rune
//
//  Created by Sako Hovaguimian on 4/10/25.
//


import SwiftUI

struct CommonCodeInputView: View {
    
    @Binding var codeInput: String
    @FocusState private var focusedField: Bool
    
    var maxCharacterCount: Int = 6
    var accentColor: ColorSource = DesignSystem.shared.accent
    var inputTextColor: ColorSource = DesignSystem.shared.background(.primary)
    var backgroundColor: ColorSource = DesignSystem.shared.background(.tertiary)
    
    var body: some View {
        
        content()
        
            .onChange(of: self.codeInput, { oldValue, newValue in
                
                if self.codeInput.count > self.maxCharacterCount {
                    self.codeInput = String(self.codeInput.dropLast())
                }
                
            })
            .keyboardType(.numberPad)
        
    }
    
    // MARK: - VIEWS -
    
    private func content() -> some View {
        
        HStack(spacing: DesignSystem.shared.spacing(.small)) {
            
            ForEach(0..<self.maxCharacterCount, id: \.self) { i in
                
                let character = getCharacterForIndex(i)
                let isCurrentField = getCurrentIndex()
                
                codeInputItemView(character: character)
                    .frame(maxWidth: 120, maxHeight: 120)
                    .frame(height: 60)
                    .background(self.backgroundColor.source())
                    .cornerRadius(.small2)
                    .appShadow()
                    .overlay(alignment: .bottom, content: {
                        
                        let isActiveColor = (self.focusedField == true && (isCurrentField == i))
                        border(isActiveColor: isActiveColor)
                        
                    })
                
                    .overlay(alignment: .bottom, content: {
                        
                        let isCurrent = (isCurrentField == i)
                        let isActiveColor = (self.focusedField == true && isCurrent)
                        
                        activeLine(isActiveColor: isActiveColor)
                        
                    })
                
                
            }
                    
        }
        .overlay {
            textfieldOverlay()
        }
        
    }
    
    private func codeInputItemView(character: String?) -> some View {
        
        Text(character ?? "-")
            .lineLimit(1, reservesSpace: true)
            .fontWeight(.heavy)
            .appFont(with: .title(.t10))
            .foregroundStyle(character == nil ? self.inputTextColor.source() : self.accentColor.source())
        
    }
    
    private func activeLine(isActiveColor: Bool) -> some View {
        
        RoundedRectangle(cornerRadius: DesignSystem.shared.radius(.small2))
            .stroke(isActiveColor ? self.accentColor.source() : ColorSource.color(.clear).source(), lineWidth: 2)
            .frame(height: 1)
            .padding(.bottom, .small)
            .padding(.horizontal, .custom(12))
            .transition(.move(edge: .bottom).combined(with: .opacity).combined(with: .scale))
            .animation(isActiveColor ? .spring(duration: 0.30).repeatForever(autoreverses: true) : nil, value: isActiveColor)
        
    }
    
    private func border(isActiveColor: Bool) -> some View {
        
        RoundedRectangle(cornerRadius: DesignSystem.shared.radius(.small2))
            .trim(from: isActiveColor ? 0 : 1, to: 1)
            .stroke(
                isActiveColor ? self.accentColor.source() : ColorSource.color(.clear).source(),
                lineWidth: 3
            )
            .animation(isActiveColor ? .smooth(duration: 0.5) : nil, value: isActiveColor)
        
    }
    
    private func textfieldOverlay() -> some View {
        
        TextField("", text: self.$codeInput)
            .foregroundStyle(.clear)
            .background(Color.clear)
            .tint(Color.clear)
            .frame(height: 64)
            .focused(self.$focusedField)
        
    }
    
    // MARK: - BUSINESS -
    
    private func getCharacterForIndex(_ index: Int) -> String? {
        
        if let text = self.codeInput[index] {
            return String(text)
        }
        
        return nil
        
    }
    
    private func getCurrentIndex() -> Int {
        
        let lastIndex = self.maxCharacterCount - 1
        let isOnLastIndex = self.codeInput.count >= self.maxCharacterCount
        
        if self.codeInput.isEmpty {
            return 0
        }
        else if isOnLastIndex {
            return lastIndex
        }
        else {
            return self.codeInput.count
        }

    }
    
}

#Preview {
    
    @Previewable @State var codeInput: String = ""
    
    AppBaseView {
        
        CommonCodeInputView(
            codeInput: $codeInput,
            maxCharacterCount: 6
        )
        .padding(.horizontal, 32)
        
    }
    .preferredColorScheme(.dark)
                
}
