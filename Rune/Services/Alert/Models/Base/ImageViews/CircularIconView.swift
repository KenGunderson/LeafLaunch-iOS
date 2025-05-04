//
//  CircularIconView.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 8/4/23.
//

import SwiftUI

struct CircularIconView: View {
    
    var foregroundColor: Color
    var backgroundColor: AppBackgroundStyle = .color(ThemeManager.shared.background(.tertiary))
    
    var size: CGFloat

    var systemImage: String? = nil
    var image: String? = nil
    
    var imageSize: CGFloat {
        return self.size / 2
    }
    
    var body: some View {

        return ZStack {
            
            Circle()
                .fill(self.backgroundColor.backgroundStyle())
                .frame(width: self.size, height: self.size)
            
            if let systemImage {
                
                Image(systemName: systemImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: self.imageSize, height: self.imageSize)
                    .foregroundColor(self.foregroundColor)
                
            }
            else if let image {
                
                Image(image)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: self.imageSize, height: self.imageSize)
                    .foregroundColor(self.foregroundColor)
                
            }
            
        }
        
    }
    
}

struct BackButton: View {
    
    private var backgroundColor: AppBackgroundStyle
    private var backAction: (() -> ())
    
    init(backgroundColor: AppBackgroundStyle = .color(ThemeManager.shared.background(.quad)),
         backAction: @escaping () -> Void) {
        
        self.backgroundColor = backgroundColor
        self.backAction = backAction
        
    }
    
    var body: some View {
        
        CircularIconView(
            foregroundColor: .black,
            backgroundColor: self.backgroundColor,
            size: 32,
            systemImage: "arrow.left"
        )
        .asButton {
            self.backAction()
        }
        
    }
    
}

#Preview {
    
    CircularIconView(
        foregroundColor: .white,
        backgroundColor: .color(.pink),
        size: 128,
        systemImage: "person.fill"
    )
    .asButton {
        print("Something")
    }
    
}

#Preview {
 
    BackButton {
        print("Tapped Back Button")
    }
    
}
