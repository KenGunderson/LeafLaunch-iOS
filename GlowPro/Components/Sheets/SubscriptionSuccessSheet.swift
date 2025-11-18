//
//  SubscriptionSuccessSheet.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 11/14/25.
//

import SwiftUI

struct SubscriptionSuccessSheet: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var isOn = false
    let dismissAction: () -> Void
    
    var message: String {
        
        return """
            All set! Your GlowPro subscription is officially live.
            
            You now have access to the complete toolkit designed to keep you organized, elevate your photography workflow, and help your business operate with clarity and ease.
            
            Every feature — from client management to powerful capture tools — is now working in your favor.
            Here’s to your next chapter: brighter, smoother, and more powerful than ever. ✨
            """
        
    }
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            backgroundView()
            confetti()
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
        .presentationBackground(Style.shared.background(.primary).source())
        
    }
    
    private func backgroundView() -> some View {
        
        Style.shared.background(.primary)
            .view()
            .ignoresSafeArea()
        
    }
    
    private func confetti() -> some View {
        
        ConfettiView(
            trigger: self.$isOn,
            settings: .glowPro()
        )
        
    }
    
    private func content() -> some View {
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.small)) {
            
            Text("Subscribed 🎉")
                .appFont(with: .HEADER_4)
                .foregroundStyle(Style.shared.textColor(.title).source())
            
            Text(self.message)
                .appFont(with: .BODY_3)
                .foregroundStyle(Style.shared.textColor(.title).source())
                .lineLimit(nil)
            
        }
        .padding(.vertical, .large)
        .padding(.horizontal, .medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
    private func bottomBarView() -> some View {
        
        CommonButton(title: "Done") {
            
            dismissAction()
            dismiss()
            
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
        ChecklistCompleteSheet()
    }
    
}
