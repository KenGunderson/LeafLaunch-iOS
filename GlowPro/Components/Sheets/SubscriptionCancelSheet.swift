//
//  SubscriptionCancelSheet.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 11/17/25.
//

import SwiftUI

struct SubscriptionCancelSheet: View {
    
    @Environment(\.dismiss) private var dismiss
        
    let cancelAction: () -> Void
    let dismissAction: () -> Void
    
    var message: String {

        return """
            Before you cancel, please note: 

            • You’ll lose access to GlowPro’s premium photo tools and organized client timelines.
            • Your photos stay safe, but pro features turn off after this billing cycle.

            We understand if your needs are changing. Sometimes you just need a breather or a reset. We just want to be sure this feels intentional, not rushed.

            If GlowPro still helps you stay organized and confident, you can keep your plan active with no interruption. Otherwise, you can continue to cancel.
            """
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
    
    private func content() -> some View {
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.small)) {
            
            Text("Cancel Subscription?")
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
        
        VStack(spacing: Style.shared.spacing(.small2)) {
            
            CommonButton(
                title: "Cancel Subscription",
                backgroundStyle: Style.shared.background(.error)
            ) {
                
                cancelAction()
                dismiss()
                
            }
            
            Text("Close")
                .appFont(with: .TITLE_4)
                .foregroundStyle(Style.shared.textColor(.title).source())
                .asButton {
                    
                    dismissAction()
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
        
        SubscriptionCancelSheet {
            // Cancel Action
        } dismissAction: {
            // Dismiss Action
        }

        
    }
    
}
