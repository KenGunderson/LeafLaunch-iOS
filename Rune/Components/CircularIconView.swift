//
//  CircularIconView.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 8/4/23.
//

import SwiftUI

struct CircularIconView: View {
    
    var foregroundColor: ColorSource = .color(ThemeManager.shared.accentColor())
    var backgroundColor: ColorSource = .color(ThemeManager.shared.background(.tertiary))
    
    var size: CGFloat

    var systemImage: String? = nil
    var image: String? = nil
    
    var imageSize: CGFloat {
        return self.size / 2
    }
    
    var body: some View {

        return ZStack {
            
            Circle()
                .fill(self.backgroundColor.source())
                .frame(width: self.size, height: self.size)
            
            if let systemImage {
                
                Image(systemName: systemImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: self.imageSize, height: self.imageSize)
                    .foregroundStyle(self.foregroundColor.source())
                
            }
            else if let image {
                
                Image(image)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: self.imageSize, height: self.imageSize)
                    .foregroundStyle(self.foregroundColor.source())
                
            }
            
        }
        
    }
    
}

struct BackButton: View {
    
    private var backgroundColor: ColorSource
    private var backAction: (() -> ())
    
    init(backgroundColor: ColorSource = .color(ThemeManager.shared.background(.quad)),
         backAction: @escaping () -> Void) {
        
        self.backgroundColor = backgroundColor
        self.backAction = backAction
        
    }
    
    var body: some View {
        
        CircularIconView(
            foregroundColor: .color(.black),
            backgroundColor: self.backgroundColor,
            size: 32,
            systemImage: "arrow.left"
        )
        .asButton {
            self.backAction()
        }
        
    }
    
}

struct FavoriteButton: View {
    
    private var isFavorited: Bool
    private var backgroundColor: ColorSource
    private var favoriteAction: (() -> ())
    
    init(isFavorited: Bool,
         backgroundColor: ColorSource = .material(.ultraThinMaterial),
         favoriteAction: @escaping () -> Void) {
        
        self.isFavorited = isFavorited
        self.backgroundColor = backgroundColor
        self.favoriteAction = favoriteAction
        
    }
    
    var body: some View {
        
        CircularIconView(
            foregroundColor: self.isFavorited ? .color(.yellow) : .color(.black),
            backgroundColor: self.backgroundColor,
            size: 40,
            systemImage: self.isFavorited ? "star.fill" : "star"
        )
        .contentTransition(.symbolEffect)
        .asButton {
            self.favoriteAction()
        }
        
    }
    
}

#Preview("Generic") {
    
    CircularIconView(
        foregroundColor: .color(.white),
        backgroundColor: .color(.pink),
        size: 128,
        systemImage: "person.fill"
    )
    .asButton {
        print("Something")
    }
    
}

#Preview("Back") {
 
    BackButton {
        print("Tapped Back Button")
    }
    
}

#Preview("Favorite") {
    
    @Previewable @State var isFavorited: Bool = false
    
    AppBaseView {
        
        FavoriteButton(isFavorited: isFavorited) {
            
            withAnimation {
                isFavorited.toggle()
            }
            
        }
        
    }
    
}
