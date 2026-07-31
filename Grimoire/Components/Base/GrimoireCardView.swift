//
//  GrimoireCardView.swift
//  Grimoire
//

import SwiftUI

struct GrimoireCardView<Content: View>: View {

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

        AppCardView(
            cornerRadius: .medium2,
            shadow: .subtle
        ) {

            VStack(
                alignment: .leading,
                spacing: Style.shared.spacing(.small)
            ) {

                Text(self.title)
                    .appFont(with: .TITLE_4)
                    .foregroundStyle(.text(.title))

                self.content

            }

        }

    }

}
