//
//  EnvironmentAlertView.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 10/25/24.
//

import SwiftUI

struct EnvironmentAlertView: View {
    
    let title: String
    let message: String
    let image: Image
    let imageColor: ColorSource
    let buttonTitle: String
    let buttonColor: ColorSource
    let action: (() -> ())
    
    var body: some View {
    
        VStack {
            
            VStack(spacing: Style.shared.spacing(.small)) {
                
                Text(self.title)
                    .appFont(with: .TITLE_T10)
                    .foregroundStyle(Style.shared.textColor(.title).source())
                    .multilineTextAlignment(.center)
                
                Text(self.message)
                    .appFont(with: .BODY_B10)
                    .lineLimit(nil)
                    .foregroundStyle(Style.shared.textColor(.body).source())
                    .multilineTextAlignment(.center)
                
            }
            .frame(maxWidth: .infinity, alignment: . center)
            
            self.image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: 200)
                .frame(maxHeight: 200)
                .foregroundStyle(self.imageColor.source())
                .appShadow()
                .padding(.top, Style.shared.spacing(.medium))
                .padding(.horizontal, Style.shared.spacing(.extraLarge))
            
            CommonButton(
                title: self.buttonTitle,
                backgroundStyle: self.buttonColor
            ) {
                action()
            }
            .padding(.top, Style.shared.spacing(.extraLarge))
            
        }
        .padding(32)
        .background(Style.shared.background(.tertiary).source())
        .cornerRadius(Style.shared.radius(.large))
        .frame(maxWidth: .infinity, alignment: . center)
        .padding(.horizontal, 32)
        .padding(.bottom, 200)
        
    }
    
}

#Preview {
    
    EnvironmentAlertView(
        title: "Check This Out!",
        message: "This is a cool card that we use to present special modals",
        image: Image(systemName: "info.circle"),
        imageColor: Style.shared.accent,
        buttonTitle: "Next",
        buttonColor: Style.shared.accent) {
            
        }
        .padding(.horizontal, 64)
    
}
