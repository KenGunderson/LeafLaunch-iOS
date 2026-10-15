//
//  BubbleTabBarView.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 7/30/26.
//

import SwiftUI

struct BubbleTabBarView: View {

    @Environment(\.style) private var style

    @Binding var selectedTab: Tab

    var body: some View {

        HStack(spacing: self.style.spacing(.none)) {

            ForEach(Tab.allCases, id: \.self) { tab in

                TabItemView(
                    tab: tab,
                    selectedTab: self.$selectedTab,
                    badgeCount: 0
                )
                .frame(maxWidth: .infinity)
                .modifier(
                    TabSelectionAnimation(
                        isSelected: self.selectedTab == tab
                    )
                )

            }

        }
        .frame(maxWidth: .infinity)
        .padding(.top, self.style.spacing(.medium))
        .background(.backgroundTappable)
        .background(alignment: .bottom) {

            UnevenRoundedRectangle(
                cornerRadii: .init(
                    topLeading: 42,
                    bottomLeading: 0,
                    bottomTrailing: 0,
                    topTrailing: 42
                ),
                style: .continuous
            )
            .fill(self.style.background(.secondary))
            .ignoresSafeArea(.container, edges: .bottom)

        }
        .appShadow(.card)

    }

}

private struct TabSelectionAnimation: ViewModifier {

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let isSelected: Bool

    struct Values {

        var scale: CGFloat = 1
        var opacity: Double = 1
        var y: CGFloat = 0

    }

    func body(content: Content) -> some View {

        content
            .opacity(self.isSelected ? 1 : 0.62)
            .scaleEffect(self.reduceMotion || self.isSelected ? 1 : 0.97)
            .animation(self.reduceMotion ? nil : .bouncy, value: self.isSelected)
            .keyframeAnimator(
                initialValue: Values(),
                trigger: self.isSelected
            ) { view, value in
                view
                    .scaleEffect(self.isSelected && !self.reduceMotion ? value.scale : 1)
                    .opacity(self.isSelected && !self.reduceMotion ? value.opacity : 1)
                    .offset(y: self.isSelected && !self.reduceMotion ? value.y : 0)
            } keyframes: { _ in
                KeyframeTrack(\.scale) {
                    CubicKeyframe(0.98, duration: 0.06)
                    CubicKeyframe(1.045, duration: 0.14)
                    CubicKeyframe(1, duration: 0.18)
                }

                KeyframeTrack(\.opacity) {
                    CubicKeyframe(0.88, duration: 0.06)
                    CubicKeyframe(1, duration: 0.20)
                }

                KeyframeTrack(\.y) {
                    CubicKeyframe(1.5, duration: 0.06)
                    CubicKeyframe(-1.5, duration: 0.14)
                    CubicKeyframe(0, duration: 0.18)
                }
            }

    }

}
