//
//  LeafLaunchCardView.swift
//  LeafLaunch
//

import SwiftUI

struct LeafLaunchCardView<Content: View>: View {

    @Environment(\.style) private var style

    private let title: String
    private let content: Content

    init(
        title: String,
        @ViewBuilder content: () -> Content
    ) {

        self.title = title
        self.content = content()

    }

    var body: some View {

        CommerceSurface {

            VStack(
                alignment: .leading,
                spacing: self.style.spacing(.small)
            ) {

                Text(self.title)
                    .appFont(with: .TITLE_4)
                    .foregroundStyle(.text(.title))

                self.content

            }

        }

    }

}
