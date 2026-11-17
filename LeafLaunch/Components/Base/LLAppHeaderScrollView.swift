//
//  LLAppHeaderScrollView.swift
//  LeafLaunch
//

import SwiftUI

struct LLAppHeaderScrollView<NavBarContent: View, ScrollViewContent: View>: View {

    @State private var isRefreshing = false

    private let horizontalPadding: RNTheme.SpacingKey
    private let onRefresh: (() async -> Void)?
    private let navBarContent: NavBarContent
    private let scrollViewContent: ScrollViewContent

    init(horizontalPadding: RNTheme.SpacingKey = LLSpacing.pageInset,
         onRefresh: (() async -> Void)? = nil,
         @ContentBuilder navBarContent: () -> NavBarContent,
         @ContentBuilder scrollViewContent: () -> ScrollViewContent) {

        self.horizontalPadding = horizontalPadding
        self.onRefresh = onRefresh

        self.navBarContent = navBarContent()
        self.scrollViewContent = scrollViewContent()

    }

    var body: some View {

        if let onRefresh = self.onRefresh {

            RNHeaderScrollView(
                horizontalPadding: self.horizontalPadding,
                refreshConfiguration: RNHeaderScrollViewRefreshConfiguration(
                    isRefreshing: self.$isRefreshing,
                    onRefresh: onRefresh,
                    indicator: { context in
                        LLRefreshIndicator(context: context)
                    }
                )
            ) {
                self.navBarContent
            } scrollViewContent: {
                self.scrollViewContent
            }

        } else {

            RNHeaderScrollView(horizontalPadding: self.horizontalPadding) {
                self.navBarContent
            } scrollViewContent: {
                self.scrollViewContent
            }

        }

    }

}

#Preview {

    LLAppHeaderScrollView {

        NavHeader(title: MockCustomerModels.store.name)

    } scrollViewContent: {

        CommerceSurface {

            Text(MockCustomerModels.locationDetails.location.name)
                .runeFont(with: .TITLE_4)
                .runeTextColor(.title)

        }

    }
    .withMockPreviews()

}
