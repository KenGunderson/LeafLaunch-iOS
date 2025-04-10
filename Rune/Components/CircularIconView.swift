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

    var imageSource: ImageSource
    
    var imageSize: CGFloat {
        return self.size / 2
    }
    
    var body: some View {

        ZStack {
            
            Circle()
                .fill(self.backgroundColor.source())
                .frame(width: self.size, height: self.size)
            
            self.imageSource
                .view()
                .scaledToFit()
                .frame(width: self.imageSize, height: self.imageSize)
                .foregroundStyle(self.foregroundColor.source())
            
        }
        
    }
    
}

struct BackButton: View {
    
    private var backgroundColor: ColorSource
    private var size: CGFloat = 32
    private var backAction: (() -> ())
    
    init(backgroundColor: ColorSource = .color(ThemeManager.shared.background(.quad)),
         size: CGFloat = 32,
         backAction: @escaping () -> Void) {
        
        self.backgroundColor = backgroundColor
        self.size = size
        self.backAction = backAction
        
    }
    
    var body: some View {
        
        CircularIconView(
            foregroundColor: .color(.black),
            backgroundColor: self.backgroundColor,
            size: self.size,
            imageSource: .systemImage("arrow.left")
        )
        .asButton {
            self.backAction()
        }
        
    }
    
}

struct FavoriteButton: View {
    
    private var isFavorited: Bool
    private var backgroundColor: ColorSource
    private var size: CGFloat = 32
    private var favoriteAction: (() -> ())
    
    init(isFavorited: Bool,
         backgroundColor: ColorSource = .material(.ultraThinMaterial),
         size: CGFloat = 32,
         favoriteAction: @escaping () -> Void) {
        
        self.isFavorited = isFavorited
        self.backgroundColor = backgroundColor
        self.size = size
        self.favoriteAction = favoriteAction
        
    }
    
    var body: some View {
        
        CircularIconView(
            foregroundColor: self.isFavorited ? .color(.yellow) : .color(.black),
            backgroundColor: self.backgroundColor,
            size: self.size,
            imageSource: .systemImage(self.isFavorited ? "star.fill" : "star")
        )
        .contentTransition(.symbolEffect)
        .asButton {
            self.favoriteAction()
        }
        
    }
    
}

#Preview("Generic") {
    
    AppBaseView {
        
        CircularIconView(
            foregroundColor: .color(.white),
            backgroundColor: .color(.pink),
            size: 128,
            imageSource: .systemImage("person.fill")
        )
        .asButton {
            print("Something")
        }
        
    }
    
}

#Preview("Back") {
    
    AppBaseView {
        
        BackButton {
            print("Tapped Back Button")
        }
        
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
