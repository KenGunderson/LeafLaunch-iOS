//
//  LeafLaunchCardView.swift
//  LeafLaunch
//

import SwiftUI

struct LeafLaunchCardView<Content: View>: View {

    @Environment(\.style) private var style

    private let title: String
    private let content: Content

    init(title: String,
         @ContentBuilder content: () -> Content) {

        self.title = title
        self.content = content()

    }

    var body: some View {

        CommerceSurface {

            VStack(
                alignment: .leading,
                spacing: self.style.spacing(LLSpacing.groupedContent)
            ) {

                Text(self.title)
                    .runeFont(with: LeafLaunchThemeTokens.headingFont)
                    .runeTextColor(.title)

                self.content

            }

        }

    }

}
