//
//  AvatarView.swift
//  Rune
//
//  Created by Sako Hovaguimian on 4/10/25.
//

import SwiftUI

struct AvatarView: View {
    
    public enum AvatarStyle {
        
        case initials(name: String)
        case image(ImageSource)
        
    }
    
    @State private var size: CGFloat = 0
    
    var style: AvatarStyle
    var foregroundColor: ColorSource
    var backgroundColor: ColorSource
    var clipShape: AnyShape = .init(.circle)
    
    var imageSize: CGFloat {
        return self.size / 2
    }
        
    init(style: AvatarStyle,
         foregroundColor: ColorSource = Style.shared.accent,
         backgroundColor: ColorSource = Style.shared.background(.tertiary),
         clipShape: AnyShape = .init(.circle)) {
        
        self.style = style
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.clipShape = clipShape
        
    }
    
    var body: some View {
        
        ZStack {
            
            RoundedRectangle(cornerRadius: 0)
                .fill(self.backgroundColor.source())
                .aspectRatio(contentMode: .fit)
                .clipShape(self.clipShape)
                
            switch self.style {
            case .initials(let name):
                
                Text(formattedName(name))
                    .font(Font(UIFont.systemFont(ofSize:(0.50 * self.size), weight: .semibold)))
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
        .clipShape(self.clipShape)
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
        
        VStack(spacing: Style.shared.spacing(.medium)) {
            
            AvatarView(style: .initials(name: "1 "))
            
            AvatarView(
                style: .initials(name: "Sako Hovaguimian"),
                clipShape: .init(.rect(cornerRadius: 32))
            )
            
            AvatarView(style: .image(.systemImage("person.fill")))
            
            AvatarView(style: .image(.image(.prize)))
                .asButton {
                    print("Some Button Test")
                }
            
        }
        
    }
    
}
