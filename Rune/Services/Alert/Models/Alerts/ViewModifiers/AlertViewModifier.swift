//
//  TestCustomAlertOverlayView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 8/1/23.
//

import SwiftUI

struct AlertViewModifier: ViewModifier {
    
    @Binding private var isPresented: Bool
    private let alertStyle: AlertStyle
    private var shouldDismissOnTouch: Bool
    
    init(isPresented: Binding<Bool>,
         shouldDismissOnTouch: Bool = false,
         alertStyle: AlertStyle) {
        
        self._isPresented = isPresented
        self.shouldDismissOnTouch = shouldDismissOnTouch
        self.alertStyle = alertStyle
        
    }
    
    func body(content: Content) -> some View {
        
        content
            .overlay {
                
                ZStack {
                    
                    if self.isPresented {
                        
                        Color.black
                            .opacity(0.6)
                            .ignoresSafeArea()
                            .onTapGesture {
                                
                                if self.shouldDismissOnTouch {
                                    self.isPresented = false
                                }
                                
                            }
                        
                        switch alertStyle {
                        case .normal(let appAlert):
                            
                            AppAlertView(
                                alert: appAlert,
                                isPresented: self.$isPresented
                            )
                            .centerVertically()
                            
                        case .textField(let appAlert, let action):
                            
                            AlertTextFieldView(
                                alert: appAlert,
                                isPresented: self.$isPresented) { email in
                                action(email)
                            }
                            .centerVertically()
                            
                        case .simpleError(let message, let action):
                            
                            AppAlertView(
                                alert: .init(
                                    title: "Oh No!",
                                    message: message,
                                    primaryButtonTitle: "Okay",
                                    primaryButtonAction: action,
                                    primaryButtonBackgroundColor: .color(.red)
                                ),
                                isPresented: self.$isPresented
                            )
                            .centerVertically()
                            
                        case .simpleSuccess(let message, let action):
                            
                            AppAlertView(
                                alert: .init(
                                    title: "Success!",
                                    message: message,
                                    primaryButtonTitle: "Okay",
                                    primaryButtonAction: action,
                                    primaryButtonBackgroundColor: Style.shared.accent,
                                    primaryButtonTextColor: .color(.white)
                                ),
                                isPresented: self.$isPresented
                            )
                            .centerVertically()
                            
                        case .success(let message, let actionColor, let actionTitleColor, let action):
                            
                            AppAlertView(
                                alert: .init(
                                    title: "Success!",
                                    message: message,
                                    primaryButtonTitle: "Okay",
                                    primaryButtonAction: action,
                                    primaryButtonBackgroundColor: .color(actionColor),
                                    primaryButtonTextColor: .color(actionTitleColor)
                                ),
                                isPresented: self.$isPresented
                            )
                            .centerVertically()
                            
                        case .forgotPassword(let action):
                            
                            AlertTextFieldView(
                                alert: .init(
                                    title: "Forgot Your Password?",
                                    message: "Enter the email below that you would like us to send the recovery email to.",
                                    primaryButtonTitle: "Okay",
                                    primaryButtonAction: {}
                                ),
                                isPresented: self.$isPresented,
                                action: action,
                                dismissAction: {
                                    self.isPresented = false
                                }
                            )
                            .centerVertically()
                            
                        }
                        
                    }
                    
                }
                .frame(height: UIScreen.main.bounds.height)
                .animation(.easeOut(duration: 0.3), value: self.isPresented)
                
            }
//            .ignoresSafeArea(.keyboard, edges: .bottom)
        
    }
    
}

extension View {
    
    func alertView(isPresented: Binding<Bool>,
                   shouldDismissOnTouch: Bool = false,
                   alertStyle: AlertStyle) -> some View {
        
        self.modifier(AlertViewModifier(
            isPresented: isPresented,
            shouldDismissOnTouch: shouldDismissOnTouch,
            alertStyle: alertStyle
        ))
        
    }
    
}
