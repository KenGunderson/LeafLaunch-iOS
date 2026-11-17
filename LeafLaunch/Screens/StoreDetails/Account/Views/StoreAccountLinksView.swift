//
//  StoreAccountLinksView.swift
//  LeafLaunch
//
//  Created by KC Gunderson on 10/17/26.
//

import SwiftUI

struct StoreAccountLinksView: View {

    @Environment(\.style) private var style

    let locationName: String?
    let hasSelectedLocation: Bool
    let favoritesAction: () -> Void
    let locationAction: () -> Void

    var body: some View {

        LLAppCardView(
            verticalPadding: .none,
            horizontalPadding: .none,
            cornerRadius: .large
        ) {

            VStack(spacing: self.style.spacing(LLSpacing.none)) {

                accountLink(
                    title: String(localized: "Saved Products"),
                    systemImage: "heart",
                    action: self.favoritesAction
                )
                .disabled(!self.hasSelectedLocation)

                LLDivider()

                accountLink(
                    title: String(localized: "Your Store"),
                    subtitle: self.locationName ?? String(localized: "Choose A Location"),
                    systemImage: "mappin.and.ellipse",
                    action: self.locationAction
                )

            }

        }

    }

    @ContentBuilder
    private func accountLink(title: String,
                             subtitle: String? = nil,
                             systemImage: String,
                             action: @escaping () -> Void) -> some View {

        HStack(spacing: self.style.spacing(LLSpacing.listRow)) {

            RNImageSource.systemImage(systemImage)
                .view(shouldResize: false)
                .runeFont(with: .TITLE_6)
                .runeTextColor(.title)
                .frame(width: self.style.spacing(.large2))

            VStack(
                alignment: .leading,
                spacing: self.style.spacing(LLSpacing.metadata)
            ) {

                Text(title)
                    .runeFont(with: .TITLE_3)
                    .runeTextColor(.title)

                if let subtitle {

                    Text(subtitle)
                        .runeFont(with: .BODY_1)
                        .runeTextColor(.body)

                }

            }
            .fixedSize(
                horizontal: false,
                vertical: true
            )
            .frame(maxWidth: .infinity, alignment: .leading)

            RNImageSource.systemImage("chevron.right")
                .view(shouldResize: false)
                .runeFont(with: .TITLE_1)
                .runeTextColor(.placeholder)

        }
        .runePadding(LLSpacing.pageInset)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .runeAsButton(action: action)

    }

}
