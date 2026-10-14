//
//  SplashScreenIntroView.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 9/6/25.
//

import SwiftUI

struct SplashScreenIntroView: View {
    
    private enum Phase {
        
        case explode
        case completed
        
    }
    
    @Binding var isLoading: Bool
        
    private let text: String
    private let explodeStagger: Double
    private let jumpHeight: CGFloat

    init(isLoading: Binding<Bool>,
         text: String,
         explodeStagger: Double = 0.18,
         jumpHeight: CGFloat = 100) {
        
        self._isLoading = isLoading
        self.text = text
        self.explodeStagger = explodeStagger
        self.jumpHeight = jumpHeight
        
    }
        
    @State private var currentPhase: Phase = .explode
    @State private var lettersShown: [Bool] = []
    
    @State private var completionScale: Bool = false
    @State private var completionBackground: Bool = false
    
    public var body: some View {
        
        wordsView()
            .onAppear {
                setupState()
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
        
    }
    
    @ViewBuilder
    private func wordsView() -> some View {

        let foregroundStyle: ColorSource = self.completionBackground ? .color(.white) : .foreground(.primary)
        let backgroundStyle: ColorSource = self.completionBackground ? .foreground(.primary) : .background(.primary)
        
        HStack(spacing: 0) {
            
            ForEach(Array(self.text.enumerated()), id: \.offset) { index, character in
                
                LetterJumpView(
                    character: character,
                    jumpHeight: self.jumpHeight,
                    isShown: self.lettersShown[safe: index] ?? false
                )
                .foregroundStyle(foregroundStyle)
                
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundStyle)
        .background {
            
            VStack {
                
                Rectangle()
                    .fill(backgroundStyle)
                    .frame(height: self.completionBackground ? nil : 0, alignment: .bottom)
                    .ignoresSafeArea()
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            
        }
        .scaleEffect(self.completionScale ? 1.30 : 1.0)
        .animation(.interpolatingSpring(mass: 0.25, stiffness: 200, damping: 4), value: self.completionScale)
        .animation(.interpolatingSpring(mass: 0.25, stiffness: 200, damping: 18), value: self.completionBackground)
        
    }
        
    private func setupState() {
        
        self.lettersShown = Array(repeating: false, count: text.count)
        self.completionScale = false
        self.completionBackground = false
        
        revealLettersWithStagger()
        
    }
    
    private func revealLettersWithStagger() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.50) {
            
            for (index, _) in text.enumerated() {
                
                let isLast = index == text.count - 1
                let delay = (Double(index) * explodeStagger)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    
                    withAnimation(.interpolatingSpring(
                        mass: 0.25,
                        stiffness: 200,
                        damping: 18
                    )) {
                        self.lettersShown[index] = true
                    }
                    
                    if isLast {
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.30) {
                            
                            self.currentPhase = .completed
                            self.completionScale = true
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                
                                self.completionBackground = true
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.70) {
                                    self.isLoading = false
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
}

fileprivate struct LetterJumpView: View {
    
    let character: Character
    let jumpHeight: CGFloat
    let isShown: Bool
    
    @State private var didJumpUp: Bool = false
    @State private var didComplete: Bool = false
    
    private var offsetY: CGFloat {
        
        guard self.isShown else { return 0 }
        
        if !self.didJumpUp { return 0 }
        if !self.didComplete { return -self.jumpHeight }
        
        return 0
        
    }
    
    private var scale: CGFloat {
        
        guard self.isShown else { return 0.96 }
        return self.didComplete ? 1.0 : 1.04
        
    }
    
    var body: some View {
        
        Text(String(self.character))
            .appFont(with: .BILLBOARD_2)
            .offset(y: self.offsetY)
            .scaleEffect(self.scale)
            .opacity(self.isShown ? 1 : 0)
            .onChange(of: self.isShown) { _, new in
                
                guard new else { return }
                
                // Jump up quickly
                withAnimation(.easeOut(duration: 0.10)) {
                    self.didJumpUp = true
                }
                
                // Then settle down with a spring, tiny overshoot polish
                withAnimation(.interpolatingSpring(mass: 0.22, stiffness: 220, damping: 17).delay(0.02)) {
                    self.didComplete = true
                }
                
            }
        
    }
    
}

#Preview {
    
    @Previewable @State var isLoading: Bool = false
    
    SplashScreenIntroView(
        isLoading: $isLoading,
        text: "LeafLaunch",
        explodeStagger: 0.125
    )
    
}
