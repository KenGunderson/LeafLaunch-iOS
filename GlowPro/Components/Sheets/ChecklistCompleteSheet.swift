//
//  ChecklistCompleteSheet.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/28/25.
//

import SwiftUI

struct ChecklistCompleteSheet: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var isOn = false
    
    var message: String {
        
        return """
            You did it — every step on your journey is complete!
            
            Your profile is polished, your business is open, your first client is added, and you’ve captured your very first photo.
            
            This is just the beginning — your foundation is set, and now the real magic of growing your business begins. Keep shining, keep creating, and let’s make every step forward count. 🌟
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
            
            Text("Way To Glow Up! 🎉")
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
            dismiss()
        }
        .padding(.horizontal, .large)
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

extension ConfettiConfig {
    
    public static func glowPro() -> ConfettiConfig {
        
        var settings = ConfettiConfig()
        
        // Emission
        settings.particleCount = 150
        settings.maxTotalParticles = 300
        
        // Spawn from near top; keep your center X
        settings.burstX = 0.278
        settings.burstY = -48
        
        // Rain vibe: mostly vertical fall, modest initial kick so gravity does the work
        settings.burstDirection = 10000
        settings.upwardBias = 270
        settings.burstSpeedMin = 90
        settings.burstSpeedMax = 180
        settings.burstXSpread = 120
        
        // Lifetime + gravity: longer travel before fade, steady speed-up
        settings.fallDurationBase = 20
        settings.gravity = 150
        
        // Mass/drag: straighter trajectories but still natural variation
        settings.massMin = 0.1
        settings.massMax = 2.0
        settings.dragMin = 0.1
        settings.dragMax = 1.2
        
        // Wobble: wider sheet feel from a single X origin (your only spread lever here)
        settings.wobbleAmplitudeMin = 0
        settings.wobbleAmplitudeMax = 250
        settings.wobbleFrequencyMin = 0.1
        settings.wobbleFrequencyMax = 1
        settings.wobbleDecay = 0.92         // keep sway alive longer
        
        // Fade: don’t start disappearing early
        settings.fadeStartPercent = 0.96
        settings.fadeDuration = 0.12
        
        // Sizes + visuals
        settings.sizeMin = 12
        settings.sizeMax = 20
        settings.metallicEnabled = false
        settings.metallicIntensity = 0.8
        settings.shimmerIntensity = 0.4
        
        settings.colorPalette = [
            Style.shared.accent.asColor!,
            Style.shared.accent.asColor!,
            GPColor.iconPurple,
            GPColor.iconPurple,
            GPColor.iconTeal,
            GPColor.iconTeal
        ]
        
        return settings
    }
    
}
