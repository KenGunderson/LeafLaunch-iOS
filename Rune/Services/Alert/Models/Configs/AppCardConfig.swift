//
//  AppCardConfig.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 8/6/24.
//

import SwiftUI

struct ContentInset: Equatable {
    
    let top: CGFloat
    let left: CGFloat
    let bottom: CGFloat
    let right: CGFloat
    
    init(top: CGFloat = 0,
         left: CGFloat = 0,
         bottom: CGFloat = 0,
         right: CGFloat = 0) {
        
        self.top = top
        self.left = left
        self.bottom = bottom
        self.right = right
        
    }
    
    static let zero = Self.init()
    
}

struct AppCardConfig: Equatable {
    
    typealias ViewBuilder = ((@escaping () -> Void) -> AnyView)
    
    let viewBuilder: ViewBuilder
    let cornerRadius: CGFloat
    let backgroundCardInset: ContentInset
    let contentCardInset: ContentInset
    let cardBackgroundColor: ColorSource
    let shouldDismissOnOutsideTouch: Bool
    let shouldDismissOnDrag: Bool
    
    init(viewBuilder: @escaping ViewBuilder,
         cornerRadius: CGFloat,
         backgroundCardInset: ContentInset = .zero,
         contentCardInset: ContentInset = .zero,
         cardBackgroundColor: ColorSource,
         shouldDismissOnOutsideTouch: Bool = true,
         shouldDismissOnDrag: Bool = true) {
        
        self.viewBuilder = viewBuilder
        self.cornerRadius = cornerRadius
        self.backgroundCardInset = backgroundCardInset
        self.contentCardInset = contentCardInset
        self.cardBackgroundColor = cardBackgroundColor
        self.shouldDismissOnOutsideTouch = shouldDismissOnOutsideTouch
        self.shouldDismissOnDrag = shouldDismissOnDrag
        
    }
    
    // Equatable
    
    static func == (lhs: AppCardConfig, rhs: AppCardConfig) -> Bool {
        
        return lhs.cornerRadius == rhs.cornerRadius &&
        lhs.backgroundCardInset == rhs.backgroundCardInset &&
        lhs.contentCardInset == rhs.contentCardInset &&
        lhs.cardBackgroundColor == rhs.cardBackgroundColor &&
        lhs.shouldDismissOnOutsideTouch == rhs.shouldDismissOnOutsideTouch
        
    }
    
}

extension AppCardConfig {
    
    static func simpleCard(title: String,
                           subtitle: String,
                           imageResource: ImageResource,
                           buttonTitle: String) -> Self {
        
        return .init(
            viewBuilder: { dismissAction in
                
                VStack {
                    
                    VStack(alignment: .leading) {
                        
                        Text(title)
                            .appFont(with: .TITLE_T10)
                            .foregroundStyle(Style.shared.textColor(.title).source())
                        
                        Text(subtitle)
                            .appFont(with: .BODY_B10)
                            .foregroundStyle(Style.shared.textColor(.body).source())
                        
                    }
                    .frame(maxWidth: .infinity, alignment: . leading)
                    
                    Image(imageResource)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .clipShape(.rect(cornerRadius: Style.shared.radius(.large)))
                        .appShadow()
                        .padding(.top, .medium)
                    
                    CommonButton(title: buttonTitle) {
                        dismissAction()
                    }
                    .padding(.top, Style.shared.radius(.extraLarge))
                    
                }
                .frame(maxWidth: .infinity, alignment: . leading)
                .asAnyView()
                
            },
            cornerRadius: Style.shared.radius(.large),
            backgroundCardInset: .init(top: 0, left: 64, bottom: 200, right: 64),
            contentCardInset: .init(top: 32, left: 32, bottom: 32, right: 32),
            cardBackgroundColor: Style.shared.background(.tertiary),
            shouldDismissOnOutsideTouch: true
        )
        
    }
    
}
