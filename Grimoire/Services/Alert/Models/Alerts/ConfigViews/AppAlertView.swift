//
//  AppAlertView.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 8/10/23.
//

import SwiftUI

struct AppAlertView: View {
    
    let alert: AppAlertConfig
    @Binding var isPresented: Bool
    let dismissAction: (() -> ())?
    
    init(alert: AppAlertConfig,
         isPresented: Binding<Bool>) {
        
        self.alert = alert
        self._isPresented = isPresented
        self.dismissAction = nil
        
    }
    
    init(alert: AppAlertConfig,
         dismissAction: @escaping (() -> ())) {
        
        self.alert = alert
        self._isPresented = .constant(true)
        self.dismissAction = dismissAction
        
    }
    
    var body: some View {
        
        VStack(spacing: 8) {
            
            Group {
                
                Text(self.alert.title)
                    .foregroundStyle(Style.shared.textColor(.title).source())
                    .multilineTextAlignment(.center)
                    .appFont(with: .TITLE_T10)
                
                if let message = self.alert.message {
                    
                    Text(message)
                        .foregroundStyle(Style.shared.textColor(.body).source())
                        .multilineTextAlignment(.center)
                        .appFont(with: .BODY_B5)
                    
                }
                
            }
            .padding(.horizontal, 24)

            buttonStackView()
                .padding(.top, 24)
                .padding(.horizontal, 24)
            
        }
        .padding(.vertical, 24)
        .background(Style.shared.background(.primary).source())
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .padding(.horizontal, Style.shared.spacing(.extraLarge))
        .appShadow(.card)
        
    }
    
    @ViewBuilder
    func button(title: String,
                backgroundColor: ColorSource,
                foregroundColor: ColorSource) -> some View {
        
        Text(title)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(backgroundColor.source())
            .foregroundStyle(foregroundColor.source())
            .font(.headline)
            .fontWeight(.semibold)
            .clipShape(RoundedRectangle(cornerRadius: 6))
        
    }
    
    @ViewBuilder
    func buttonStackView() -> some View {
        
        HStack(spacing: 16) {
            
            Button(action: {
                
                self.isPresented = false
                self.alert.primaryButtonAction()
                self.dismissAction?()
                
            },
            label: {
                
                self.button(
                    title: self.alert.primaryButtonTitle,
                    backgroundColor: self.alert.primaryButtonBackgroundColor,
                    foregroundColor: self.alert.primaryButtonTextColor
                )
                
            })
            
            if let secondaryButtonTitle = alert.secondaryButtonTitle,
               let secondaryButtonAction = alert.secondaryButtonAction {
                
                Button(action: {
                    
                    self.isPresented = false
                    secondaryButtonAction()
                    self.dismissAction?()
                    
                },
                label: {
                    
                    self.button(
                        title: secondaryButtonTitle,
                        backgroundColor: self.alert.secondaryButtonBackgroundColor ?? self.alert.primaryButtonBackgroundColor,
                        foregroundColor: self.alert.secondaryButtonTextColor ?? self.alert.primaryButtonTextColor
                    )
                    
                })
                
            }
  
        }
        
    }
    
}
