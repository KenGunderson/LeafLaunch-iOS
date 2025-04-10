//
//  AvatarView.swift
//  Rune
//
//  Created by Sako Hovaguimian on 4/10/25.
//

import SwiftUI

struct AvatarView: View {
    
    public enum Style {
        
        case initials(name: String)
        case image(ImageSource)
        
    }
    
    @State private var size: CGFloat = 0
    
    var style: Style
    var foregroundColor: ColorSource
    var backgroundColor: ColorSource
    
    var imageSize: CGFloat {
        return self.size / 2
    }
        
    init(style: Style,
         foregroundColor: ColorSource = .color(ThemeManager.shared.accentColor()),
         backgroundColor: ColorSource = .color(ThemeManager.shared.background(.tertiary))) {
        
        self.style = style
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        
    }
    
    var body: some View {
        
        ZStack {
            
            Circle()
                .fill(self.backgroundColor.source())
            
            switch self.style {
            case .initials(let name):
                
                Text(formattedName(name))
                    .font(Font(UIFont.systemFont(ofSize:(0.40 * self.size), weight: .semibold)))
                    .fontDesign(.monospaced)
                    .foregroundStyle(self.foregroundColor.source())
                
            case .image(let imageSource):
                
                switch imageSource {
                case .image:
                    
                    imageSource
                        .view()
                        .aspectRatio(1.0, contentMode: .fit)
                        .foregroundStyle(self.foregroundColor.source())
                    
                case .systemImage(let systemImage):
                    
                    Image(systemName: systemImage)
                        .resizable()
                        .aspectRatio(1.0, contentMode: .fit)
                        .frame(width: self.imageSize, height: self.imageSize)
                        .foregroundStyle(self.foregroundColor.source())
                    
                case .remote:
                    
                    CommonImageView(style: imageSource)
                    
                }
                
            }
            
        }
        .clipShape(.circle)
        .onGeometryChange(for: CGSize.self) { proxy in
            return proxy.size
        } action: { newValue in
            self.size = newValue.width
        }

    }
    
    private func formattedName(_ name: String?) -> String {
        
        guard let name,
              !name.isEmpty else { return "" }
        
        return name.initials
        
    }
    
}

#Preview {
    
    AppBaseView {
        
        VStack(spacing: Spacing.medium.value) {
            
            AvatarView(style: .initials(name: "Sako Hovaguimian"))
            AvatarView(style: .image(.systemImage("person.fill")))
            AvatarView(style: .image(.image(.prize)))
                .asButton {
                    print("Some Button Test")
                }
            
        }
        
    }
    
}
