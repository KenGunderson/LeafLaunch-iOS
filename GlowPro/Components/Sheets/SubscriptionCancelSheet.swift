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
            Are you sure you want to cancel your GlowPro subscription?

            Before you decide, here’s a quick reminder of what canceling means:
            • You’ll lose access to premium capture tools, client organization features, and business-building workflows.
            • Your photos and data remain safe, but certain pro features will become unavailable once your billing period ends.
            
            We completely understand if GlowPro isn’t the right fit right now — life and business needs change. We just want to make sure this decision feels intentional and not accidental.

            If you’d like to continue, you can keep your subscription active with no interruptions. Otherwise, you’re welcome to proceed and we’ll guide you through the cancellation smoothly.
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
