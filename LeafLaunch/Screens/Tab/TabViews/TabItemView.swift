//
//  TabItemView.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 7/30/26.
//

import SwiftUI

struct TabItemView: View {

    @Environment(\.style) private var style

    @Binding var selectedTab: Tab

    let tab: Tab
    let badgeCount: Int

    init(tab: Tab,
         selectedTab: Binding<Tab>,
         badgeCount: Int) {

        self.tab = tab
        self._selectedTab = selectedTab
        self.badgeCount = badgeCount

    }

    var body: some View {

        let isSelectedTab = self.tab == self.selectedTab
        let foregroundColor = isSelectedTab
            ? self.style.accent
            : self.style.textColor(.body)
        let icon = isSelectedTab ? self.tab.selectedIcon : self.tab.unselectedIcon
        let badgeText = self.badgeCount > 99 ? "99+" : "\(self.badgeCount)"

        VStack(spacing: self.style.spacing(.custom(4))) {

            ImageSource
                .systemImage(icon)
                .view()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .scaleEffect(isSelectedTab ? 1.10 : 1)
                .foregroundStyle(foregroundColor.source())
                .appFont(with: .BODY_4)
                .contentTransition(.symbolEffect(.replace))
                .commonBadge(
                    contentStyle: .text(Text(badgeText)),
                    placement: .init(
                        overlapStyle: .circular,
                        offset: CGSize(width: -2, height: 2),
                        anchorOutset: 4,
                        circularOverlapOutset: 0
                    ),
                    appearance: .init(
                        foregroundStyle: .color(.white),
                        backgroundStyle: .palette(.error),
                        borderStyle: .background(.primary),
                        borderLineWidth: 1
                    ),
                    sizing: .init(
                        textFont: .TITLE_2,
                        minWidth: 16,
                        minHeight: 16,
                        horizontalPadding: .extraSmall,
                        verticalPadding: .none
                    ),
                    behavior: .init(
                        isVisible: self.badgeCount > 0,
                        factorsIntoFrame: false
                    )
                )

            Text(self.tab.title)
                .scaleEffect(isSelectedTab ? 1.10 : 1)
                .foregroundStyle(foregroundColor.source())
                .appFont(with: .BODY_1)
                .fontWeight(isSelectedTab ? .semibold : .regular)
                .transition(.opacity)
                .id(self.tab.title)

        }
        .contentShape(.rect)
        .accessibilityElement(children: .combine)
        .accessibilityValue(
            self.badgeCount > 0
                ? "\(self.badgeCount) unread messages"
                : ""
        )
        .asButton {

            withAnimation(.spring) {
                self.selectedTab = self.tab
            }

        }

    }

}
