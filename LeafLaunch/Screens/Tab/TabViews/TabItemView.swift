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
        let foregroundColor = isSelectedTab ? self.style.accent : self.style.textColor(.body)

        VStack(spacing: self.style.spacing(.extraSmall)) {

            tabIcon()

            Text(self.tab.title)
                .scaleEffect(isSelectedTab ? 1.10 : 1)
                .foregroundStyle(foregroundColor)
                .appFont(with: .BODY_1)
                .fontWeight(isSelectedTab ? .semibold : .regular)
                .transition(.opacity)
                .id(self.tab.title)

        }
        .contentShape(.rect)
        .frame(minHeight: 44)
        .asButton {
            self.selectedTab = self.tab
        }
        .animation(.bouncy, value: self.selectedTab)

    }

    @ViewBuilder
    private func tabIcon() -> some View {

        let isSelectedTab = self.tab == self.selectedTab
        let foregroundColor = isSelectedTab ? self.style.accent : self.style.textColor(.body)
        let icon = isSelectedTab ? self.tab.selectedIcon : self.tab.unselectedIcon
        let badgeText = self.badgeCount > 99 ? "99+" : "\(self.badgeCount)"

        ImageSource
            .systemImage(icon)
            .view()
            .scaledToFit()
            .frame(width: 24, height: 24)
            .scaleEffect(isSelectedTab ? 1.10 : 1)
            .foregroundStyle(foregroundColor)
            .appFont(with: .BODY_4)
            .commonBadge(
                contentStyle: .text(Text(badgeText)),
                placement: .init(
                    overlapStyle: .circular,
                    offset: CGSize(width: -2, height: 2),
                    anchorOutset: 4,
                    circularOverlapOutset: 0
                ),
                appearance: .init(
                    foregroundStyle: .text(.titleInverted),
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

    }

}
