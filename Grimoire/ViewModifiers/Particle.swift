//
//  Particle.swift
//  Rune
//
//  Created by Sako Hovaguimian on 4/23/25.
//


import SwiftUI

internal struct Particle: Identifiable {
    
    var id: UUID = .init()
    var randomX: CGFloat = 0
    var randomY: CGFloat = 0
    var scale: CGFloat = 1
    var opacity: CGFloat = 1
    
    mutating func reset() {
        
        self.randomX = 0
        self.randomY = 0
        self.scale = 1
        self.opacity = 1
        
    }
    
}

struct ParticleModifier: ViewModifier {
    
    var systemImage: String
    var font: Font
    var status: Bool
    var activeColor: ColorSource
    var inActiveColor: ColorSource
    var largeDistance: Bool = false
    
    @State private var particles: [Particle] = []
    
    func body(content: Content) -> some View {
        
        content
            .overlay(alignment: .top) {
                
                ZStack {
                    
                    ForEach(self.particles) { particle in
                        
                        Image(systemName: self.systemImage)
                            .foregroundStyle(self.status ? self.activeColor.source() : self.inActiveColor.source())
                            .scaleEffect(particle.scale)
                            .font(self.font)
                            .offset(x: particle.randomX, y: particle.randomY)
                            .opacity(particle.opacity)
                            .opacity(self.status ? 1 : 0)
                            .animation(.none, value: self.status)
                        
                    }
                    
                }
                .onAppear {
                    
                    if particles.isEmpty {
                        
                        for _ in 1...9 {
                            
                            let particle = Particle()
                            self.particles.append(particle)
                            
                        }
                        
                    }
                    
                }
                .onChange(of: status) { oldValue, newValue in
                    
                    if !newValue {
                        
                        for index in self.particles.indices {
                            self.particles[index].reset()
                        }
                        
                    } else {
                        
                        for index in self.particles.indices {
                            
                            let total: CGFloat = CGFloat(self.particles.count)
                            let progress: CGFloat = CGFloat(index) / total
                            let maxXAmount: CGFloat = largeDistance ? 300 : 100
                            let maxX: CGFloat = (progress > 0.5) ? maxXAmount : -maxXAmount
                            let maxY: CGFloat = 60
                            
                            let randomX: CGFloat = ((progress > 0.5 ? progress - 0.5 : progress) * maxX)
                            let randomY: CGFloat = ((progress > 0.5 ? progress - 0.5 : progress) * maxY) + 35
                            let randomScale: CGFloat = .random(in: 0.35...2)
                            
                            withAnimation(.interactiveSpring(
                                response: 0.6,
                                dampingFraction: 0.7,
                                blendDuration: 0.7)
                            ) {
                                
                                let extraRandomX: CGFloat = (progress < 0.5 ? .random(in: 0...10) : .random(in: -10...0))
                                let extraRandomY: CGFloat = .random(in: 0...30)
                                
                                self.particles[index].randomX = randomX + extraRandomX
                                self.particles[index].randomY = -randomY - extraRandomY
                                
                            }
                            
                            withAnimation(.easeInOut(duration: 0.4)) {
                                
                                self.particles.indices.forEach { index in
                                    self.particles[index].scale = randomScale
                                }
                                
                            }
                            
                            withAnimation(.interactiveSpring(
                                response: 0.6,
                                dampingFraction: 0.7,
                                blendDuration: 0.7)
                                .delay(0.25 + (Double(index) * 0.005))
                            ) {
                                
                                self.particles.indices.forEach { index in
                                    self.particles[index].scale = 0.001
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                    
                }
                
            }
        
    }
    
}

extension View {
    
    @ViewBuilder
    func particleEffect(systemImage: String,
                        font: Font,
                        status: Bool,
                        activeColor: ColorSource,
                        inActiveColor: ColorSource,
                        largeDistance: Bool) -> some View {
        
        modifier(ParticleModifier(
            systemImage: systemImage,
            font: font,
            status: status,
            activeColor: activeColor,
            inActiveColor: inActiveColor,
            largeDistance: largeDistance
        ))
        
    }
    
}

@ViewBuilder
func ParticleButton(systemImage: String,
                    status: Bool,
                    activeColor: ColorSource,
                    inActiveColor: ColorSource,
                    largeDistance: Bool = false,
                    onTap: @escaping () -> ()) -> some View {
    
    Button(action: {
        onTap()
    }) {
        Image(systemName: systemImage)
            .font(.title)
            .particleEffect(
                systemImage: systemImage,
                font: .title2,
                status: status,
                activeColor: activeColor,
                inActiveColor: inActiveColor,
                largeDistance: largeDistance
            )
            .foregroundStyle(activeColor.source())
            .padding(.horizontal, 18)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(activeColor.source().opacity(0.25))
            )
    }
    
}

struct ParticlePreviewView: View {
    
    @State private var isLiked: [Bool] = [false, false, false, false]
    
    var body: some View {
        
        VStack(spacing: 20) {
            
            HStack(spacing: 20) {
                
                ParticleButton(
                    systemImage: "hand.thumbsup.fill",
                    status: isLiked[0],
                    activeColor: .color(.blue),
                    inActiveColor: .color(.gray)
                ) {
                    
                    isLiked[0]
                        .toggle()
                    
                }
                
                Spacer(minLength: 0)
                
                ParticleButton(
                    systemImage: "star.fill",
                    status: isLiked[1],
                    activeColor: .color(.yellow),
                    inActiveColor: .color(.gray)
                ) {
                    
                    isLiked[1]
                        .toggle()
                    
                }
                
                Spacer(minLength: 0)
                
                ParticleButton(
                    systemImage: "heart.fill",
                    status: isLiked[2],
                    activeColor: .color(.red),
                    inActiveColor: .color(.gray)
                ) {
                    
                    isLiked[2]
                        .toggle()
                    
                }
                
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
            CommonButton(title: "Lightning Bolt ⚡️ (+3 Damage)") {
                
                isLiked[3]
                    .toggle()
                
            }
            .particleEffect(
                systemImage: "bolt.fill",
                font: .largeTitle,
                status: isLiked[3],
                activeColor: Style.shared.accent,
                inActiveColor: .color(.gray),
                largeDistance: true
            )
            
        }
        .padding(.horizontal, .large)
        
    }
    
}

#Preview {
    ParticlePreviewView()
}
