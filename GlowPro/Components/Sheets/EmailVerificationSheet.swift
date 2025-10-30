//
//  EmailVerificationSheet.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 10/30/25.
//

import SwiftUI

struct EmailVerificationSheet: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var isOn = false
    
    var title: String {
        return "Is your email correct? ✉️"
    }
    
    var message: String {
        return "Give your email one last glance to be sure. This is where we will send confirmations, updates, and a little magic as we go."
    }
    
    let email: String
    let successAction: () -> Void
    
    init(email: String,
         successAction: @escaping () -> Void) {
        
        self.email = email
        self.successAction = successAction
        
    }
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            backgroundView()
            content()
            
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        .onAppear {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                self.isOn = true
            }
            
        }
        .safeAreaInset(edge: .bottom) {
            bottomBarView()
        }
        .fixedSize(
            horizontal: false,
            vertical: true
        )
        .presentationCornerRadius(Style.shared.radius(.extraLarge))
        .presentationCompactAdaptation(.sheet)
        
    }
    
    private func backgroundView() -> some View {
        
        Style.shared.background(.primary)
            .view()
            .ignoresSafeArea()
        
    }
    
    private func content() -> some View {
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.small)) {
            
            Text(self.title)
                .appFont(with: .HEADER_4)
                .foregroundStyle(Style.shared.textColor(.title).source())
            
            Text(self.message)
                .appFont(with: .BODY_3)
                .foregroundStyle(Style.shared.textColor(.title).source())
                .lineLimit(nil)
            
            Text(self.email)
                .appFont(with: .HEADER_5)
                .foregroundStyle(Style.shared.accent.source())
            
        }
        .padding(.top, .large)
        .padding(.bottom, .custom(80))
        .padding(.horizontal, .medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
    private func bottomBarView() -> some View {
        
        VStack(spacing: Style.shared.spacing(.small)) {
            
            CommonButton(title: "Confirm") {
                
                successAction()
                dismiss()
                
            }
            
            Text("Change Email")
                .appFont(with: .TITLE_4)
                .foregroundStyle(Style.shared.textColor(.body).source())
                .asButton {
                   dismiss()
                }
            
        }
        .padding(.horizontal, .large)
        .padding(.bottom, UIDevice.isIpad ? .large : .none)
        .frame(maxWidth: .infinity)
        .background(Style.shared.background(.primary).source())
        
    }
    
}

#Preview {
    
    @Previewable @State var showSheet: Bool = false
    
    AppBaseView {
        
        CommonButton(title: "Show Sheet") {
            showSheet.toggle()
        }
        .padding(.horizontal, .large)
        
    }
    .adaptiveSheet(isPresented: $showSheet,
                   backgroundStyle: Style.shared.background(.primary)) {
        
        EmailVerificationSheet(email: "sako@me.com") {
            print("Success Action")
        }
        
    }
    
}
