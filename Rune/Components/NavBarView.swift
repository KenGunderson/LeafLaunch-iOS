//
//  NavBarView.swift
//  Rune
//
//  Created by Sako Hovaguimian on 4/23/25.
//


import SwiftUI

struct NavBarView: View {
    
    struct NavProperties {
        
        let title: String
        let subtitle: String?
        let leftButtonView: AnyView?
        let rightButtonView: AnyView?

        init(title: String,
             subtitle: String? = nil,
             leftButtonView: AnyView? = nil,
             rightButtonView: AnyView? = nil) {
            
            self.title = title
            self.subtitle = subtitle
            self.leftButtonView = leftButtonView
            self.rightButtonView = rightButtonView
            
        }
        
    }
    
    enum NavBarStyle {
        
        case content(AnyView)
        case standard(NavProperties)
        
        case scroll(NavProperties,
                    scrollOffset: CGFloat,
                    startingOffset: CGFloat,
                    scrollThreshold: CGFloat)
        
    }
    
    let navBarStyle: NavBarStyle
    let backgroundStyle: ColorSource
    
    init(navBarStyle: NavBarStyle,
         backgroundStyle: ColorSource) {
        
        self.navBarStyle = navBarStyle
        self.backgroundStyle = backgroundStyle
        
    }
    
    init(title: String,
         subtitle: String? = nil,
         leftButtonView: AnyView? = nil,
         rightButtonView: AnyView? = nil,
         navBackgroundStyle: ColorSource = Style.shared.background(.primary)) {
        
        self.navBarStyle = .standard(
            .init(
                title: title,
                subtitle: subtitle,
                leftButtonView: leftButtonView,
                rightButtonView: rightButtonView
            )
        )
        
        self.backgroundStyle = navBackgroundStyle
        
    }
    
    var body: some View {
        
        Group {
            
            switch navBarStyle {
            case .content(let content):
                
                applyCommonStyle(content)
                
            case .standard(let navProperties):
                
                applyCommonStyle(standardView(navProperties: navProperties))
                
            case .scroll(let navProperties, let scrollOffset, let startingOffset, let scrollThreshold):
                
                scrollableView(
                    navProperties: navProperties,
                    scrollOffset: scrollOffset,
                    startingOffset: startingOffset,
                    scrollThreshold: scrollThreshold
                )
            }
            
        }
        .background(backgroundView())
    
    }
    
    @ViewBuilder
    private func backgroundView() -> some View {
        
        switch self.navBarStyle {
        case .content(_),
             .standard(_):
            
            self.backgroundStyle
                .view()
                .ignoresSafeArea()
            
        case .scroll(_, let scrollOffset, _, let scrollThreshold):
            
            let opacity = calculateOpacity(
                currentOffset: scrollOffset,
                threshold: scrollThreshold
            )
            
            self.backgroundStyle
                .view()
                .ignoresSafeArea()
                .opacity(opacity)
        }
        
    }
    
    @ViewBuilder
    private func standardView(navProperties: NavProperties) -> some View {
        
        ZStack(alignment: .center) {
            
            HStack {
                
                // Left Button View
                
                Group {
                    
                    if let leftButtonView = navProperties.leftButtonView {
                        leftButtonView
                    }
                    else {
                        navProperties.rightButtonView
                            .opacity(0)
                    }
                    
                }
                
                Spacer()
                
                // Right Button View
                
                Group {
                    
                    if let rightButtonView = navProperties.rightButtonView {
                        rightButtonView
                    }
                    else {
                        
                        navProperties.leftButtonView
                            .opacity(0)
                    }
                    
                }
                
            }
            .frame(maxWidth: .infinity)
            
            // Center Title & Subtitle
            
            VStack {
                
                Text(navProperties.title)
                    .appFont(with: .TITLE_T6)
                    .fontDesign(.serif)
                    .foregroundStyle(Style.shared.textColor(.title).source())
                
                if let subtitle = navProperties.subtitle {
                    
                    Text(subtitle)
                        .appFont(with: .BODY_B5)
                        .foregroundStyle(Style.shared.textColor(.body).source())
                    
                }
                
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, 48)
            
        }
        
    }

    private func scrollableView(navProperties: NavProperties,
                                scrollOffset: CGFloat,
                                startingOffset: CGFloat,
                                scrollThreshold: CGFloat) -> some View {
        
        let opacity = calculateOpacity(
            currentOffset: scrollOffset,
            threshold: scrollThreshold
        )
        
        let yOffset = calculateYOffset(
            currentOffset: scrollOffset,
            threshold: scrollThreshold,
            startOffset: startingOffset,
            endOffset: 0
        )
                
        return ZStack {
            
            HStack {
                
                if let leftButtonView = navProperties.leftButtonView {
                    leftButtonView
                }
                
                Spacer()
                
                if let rightButtonView = navProperties.rightButtonView {
                    rightButtonView
                }
                
            }

            VStack {
                
                Text(navProperties.title)
                    .appFont(with: .TITLE_T6)
                
                if let subtitle = navProperties.subtitle {
                    
                    Text(subtitle)
                        .appFont(with: .BODY_B5)
                    
                }
                
            }
            .offset(y: yOffset)
            
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
        .clipped()
        .overlay(alignment: .bottom) {
            
            Rectangle()
                .fill(.gray.opacity(0.3))
                .frame(height: 1)
                .opacity(opacity)
            
        }
        
    }
    
    private func applyCommonStyle<V: View>(_ view: V) -> some View {
                
        return view
            .customSafeAreaPadding(
                padding: Style.shared.spacing(.none),
                for: .top
            )
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
            .overlay(alignment: .bottom) {
                
                Rectangle()
                    .fill(.gray.opacity(0.3))
                    .frame(height: 1)
                
            }
        
    }
    
    func calculateOpacity(currentOffset: CGFloat,
                          threshold: CGFloat) -> CGFloat {
        
        let scrollOffset: CGFloat = currentOffset
        let scrollOffsetThreshold: CGFloat = threshold
    
        let clampedOffset: CGFloat = min(max(scrollOffset, 0), scrollOffsetThreshold)
        return clampedOffset / scrollOffsetThreshold
        
    }
    
    func calculateYOffset(currentOffset: CGFloat,
                          threshold: CGFloat,
                          startOffset: CGFloat,
                          endOffset: CGFloat) -> CGFloat {
        
        let scrollOffset: CGFloat = currentOffset
        let scrollOffsetThreshold: CGFloat = threshold
        
        let clampedOffset = min(max(scrollOffset, 0), scrollOffsetThreshold)
        let normalizedProgress = clampedOffset / scrollOffsetThreshold
        
        return startOffset + (normalizedProgress * (endOffset - startOffset))
        
    }
    
}

// MARK: - PREVIEWS

#Preview("NavBarStyle: Basic Init", body: {
    
    ZStack(alignment: .top) {
        
        Color.black.opacity(0.8)
            .ignoresSafeArea()
        
        NavBarView(
            title: "Woah",
            subtitle: "This is a subtitle",
            leftButtonView: (Circle().fill(.red).frame(width: 32).asAnyView()),
            rightButtonView: (Circle().fill(.red).frame(width: 32).asAnyView()),
            navBackgroundStyle: .color(.green)
        )
        .background(Color.green)
        
    }
    
})

#Preview("NavBarStyle: Custom", body: {
    
    ZStack(alignment: .top) {
        
        Color.black.opacity(0.8)
            .ignoresSafeArea()
        
        NavBarView(navBarStyle: .content(
            AnyView(HStack {
                
                Circle().fill(.red)
                    .frame(width: 24)
                
                Text("This is some test")
                    .frame(maxWidth: .infinity)
                
                Circle().fill(.red)
                    .frame(width: 24)
                
            }
                   )), backgroundStyle: .color(.red))
        .background(.white)
        
    }
    
})

#Preview("NavBarStyle: Standard",
         body: {
    
    ZStack {
        
        Color.white.ignoresSafeArea()
        
        VStack(spacing: 0) {
            
            NavBarView(navBarStyle: .standard(NavBarView.NavProperties(
                title: "Welcome Home",
                subtitle: "This is fun, come over here",
                leftButtonView: (
                    Image(systemName: "arrow.left")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .background {
                            Color.black.opacity(0.000001)
                                .frame(width: 40, height: 40)
                        }
                        .onTapGesture {
                            print("Test 1")
                        }
                        .asAnyView()
                ),
                rightButtonView: (
                    Image(systemName: "xmark")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 18)
                        .background {
                            Color.black.opacity(0.000001)
                                .frame(width: 40, height: 40)
                        }
                        .onTapGesture {
                            print("Test 2")
                        }
                        .asAnyView()
                )
            )),  backgroundStyle: .color(.red))
            
            VStack {
                
                Text("Hello")
                Spacer()
                Text("Doogbye")
                
            }
            .frame(maxWidth: .infinity)
            .background(.blue)
            .ignoresSafeArea()
            
        }
        
    }
    .frame(
        maxWidth: .infinity,
        maxHeight: .infinity
    )
    
})

#Preview("NavBarStyle: Scrolling") {
    
    @Previewable @State var scrollOffset: CGFloat = 0
    
    ZStack(alignment: .top) {
        
        ScrollView {
            
            ForEach(0..<100) { _ in
                Text("123")
                    .frame(maxWidth: .infinity)
            }
           
        }
        .onScrollGeometryChange(for: CGFloat.self) { geo in
            return geo.contentOffset.y
        } action: { oldValue, newValue in
            scrollOffset = newValue
        }
        .safeAreaInset(edge: .top) {
            
            let navProperties: NavBarView.NavProperties = .init(
                title: "Welcome Home",
                subtitle: "This is fun, come over here"
            )
            
            let navBarStyle: NavBarView.NavBarStyle = .scroll(
                navProperties,
                scrollOffset: scrollOffset,
                startingOffset: 250,
                scrollThreshold: 250
            )
            
            return NavBarView(
                navBarStyle: navBarStyle,
                backgroundStyle: .color(.blue)
            )
            
        }
        
    }
    .onAppear {
        print(scrollOffset)
    }
    
}
