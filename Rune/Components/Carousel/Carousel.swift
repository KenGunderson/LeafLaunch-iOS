//
//  Carousel.swift.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 10/29/24.
//

import SwiftUI
import Combine

struct CarouselDemoItem: Identifiable {
    
    let id = UUID().uuidString
    let color: Color
    
    static func DUMMY_DATA() -> [Self] {
        
        [
            .init(color: .blue),
            .init(color: .green),
            .init(color: .indigo),
            .init(color: .purple)
        ]
        
    }
    
}

enum CarouselStyle {
    
    case auto(interval: TimeInterval)
    case manual
    
}

struct Carousel<Content: View>: View {
    
    @ViewBuilder private var content: Content
    
    @State private var scrollPosition: Int?
    @State private var isScrolling: Bool = false
    @State private var timer: Publishers.Autoconnect<Timer.TimerPublisher>? = nil
    
    @Binding private var activeIndex: Int
    @GestureState private var isHolding: Bool = false
    
    private let interitemSpacing: Theme.SpacingKey
    private let safeAreaSpacing: Theme.SpacingKey
    
    private var style: CarouselStyle!
    
    init(activeIndex: Binding<Int>,
         style: CarouselStyle,
         interitemSpacing: Theme.SpacingKey = .small,
         safeAreaSpacing: Theme.SpacingKey = .medium,
         content: () -> Content) {
        
        self._activeIndex = activeIndex
        self.style = style
        self.interitemSpacing = interitemSpacing
        self.safeAreaSpacing = safeAreaSpacing
        self.content = content()
        
    }
    
    var body: some View {
        
        GeometryReader { geo in
            
            let size = geo.size
            
            Group(subviews: content) { collection in
                
                ScrollView(.horizontal) {
                    
                    HStack(spacing: Style.shared.spacing(self.interitemSpacing)) {
                        
                        ForEach(collection.indices, id: \.self) { index in
                            
                            collection[index]
                                .frame(
                                    height: size.height
                                )
                                .containerRelativeFrame(.horizontal)
                                .id(index)
                            
                        }
                        
                    }
                    .scrollTargetLayout()
                    
                }
                .overlay(alignment: .bottom) {
                    
                    PageControl(
                        totalIndex: collection.count,
                        selectedIndex: activeIndex
                    )
                    .padding(.bottom, .medium)
                    
                }
                .scrollPosition(id: self.$scrollPosition)
                .safeAreaPadding(.horizontal, Style.shared.spacing(self.safeAreaSpacing))
                .scrollClipDisabled()
                .scrollTargetBehavior(.viewAligned)
                .scrollIndicators(.hidden)
                .onScrollPhaseChange { oldPhase, newPhase in
                    self.isScrolling = newPhase.isScrolling
                }
                .simultaneousGesture(DragGesture(minimumDistance: 0).updating(self.$isHolding, body: { _, out, _ in
                    out = true
                }))
                .if(self.timer != nil) { view in
                    
                    view
                        .onReceive(self.timer!) { _ in
                            
                            guard !self.isHolding && !self.isScrolling else { return }
                            
                            let nextIndex = (scrollPosition ?? 0) + 1
                            let isNextLast = (nextIndex == collection.count)
                            
                            withAnimation(.snappy(duration: 0.25)) {
                                scrollPosition = isNextLast ? 0 : nextIndex
                            }
                            
                        }
                    
                }
                
            }
            .onChange(of: self.scrollPosition, { oldValue, newValue in
                self.activeIndex = newValue ?? 0
            })
            .onChange(of: self.isHolding) { oldValue, newValue in
                
                if newValue {
                    cancelTimer()
                } else {
                    resetTimer()
                }
                
            }
            
        }
        .onAppear {
            resetTimer()
        }
        
    }
    
    private func cancelTimer() {
        self.timer?.upstream.connect().cancel()
    }
    
    private func resetTimer() {
        
        if case let .auto(interval) = style {
            
            self.timer = Timer.publish(
                every: interval,
                on: .main,
                in: .default
            )
            .autoconnect()
            
        } else {
            cancelTimer()
        }
        
    }
    
}

#Preview {
    
    @Previewable @State var autoIndex: Int = 0
    @Previewable @State var manualIndex: Int = 0
    
    VStack(spacing: Style.shared.spacing(.extraLarge)) {
        
        Carousel(activeIndex: $autoIndex, style: .auto(interval: 3)) {
            
            ForEach(CarouselDemoItem.DUMMY_DATA()) { item in
                
                RoundedRectangle(cornerRadius: Style.shared.radius(.medium))
                    .fill(item.color.gradient)
                    .asButton {
                        print("ACTIVE INDEX IS: \(autoIndex)")
                    }
                
            }
            
        }
        .frame(height: 120)
        
        Carousel(activeIndex: $manualIndex, style: .manual) {
            
            ForEach(CarouselDemoItem.DUMMY_DATA()) { item in
                
                RoundedRectangle(cornerRadius: Style.shared.radius(.medium))
                    .fill(item.color.gradient)
                    .asButton {
                        print("ACTIVE INDEX IS: \(manualIndex)")
                    }
                
            }
            
        }
        .frame(height: 120)
        
    }
    
}
