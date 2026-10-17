//
//  LLAppHeaderScrollView.swift
//  LeafLaunch
//

import SwiftUI

struct LLAppHeaderScrollView<NavBarContent: View, ScrollViewContent: View>: View {

    private let navBarContent: NavBarContent
    private let scrollViewContent: ScrollViewContent

    init(@ViewBuilder navBarContent: () -> NavBarContent,
         @ViewBuilder scrollViewContent: () -> ScrollViewContent) {

        self.navBarContent = navBarContent()
        self.scrollViewContent = scrollViewContent()

    }

    var body: some View {

        AppHeaderScrollView(horizontalPadding: .medium) {

            self.navBarContent

        } scrollViewContent: {

            self.scrollViewContent

        }

    }

}

#Preview {

    LLAppHeaderScrollView {

        NavHeader(title: MockCustomerModels.store.name)

    } scrollViewContent: {

        CommerceSurface {

            Text(MockCustomerModels.locationDetails.location.name)
                .appFont(with: .TITLE_4)
                .foregroundStyle(.text(.title))

        }

    }
    .withMockPreviews()

}
