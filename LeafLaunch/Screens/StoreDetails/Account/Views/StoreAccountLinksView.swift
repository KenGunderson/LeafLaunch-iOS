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

        LLAppCardView(verticalPadding: .none, horizontalPadding: .none, cornerRadius: .large) {

            VStack(spacing: 0) {

                accountLink(
                    title: String(localized: "Saved Products"),
                    systemImage: "heart",
                    action: self.favoritesAction
                )
                .disabled(!self.hasSelectedLocation)

                Divider().overlay(self.style.background(.border))

                accountLink(
                    title: String(localized: "Your Store"),
                    subtitle: self.locationName ?? String(localized: "Choose a location"),
                    systemImage: "mappin.and.ellipse",
                    action: self.locationAction
                )

            }

        }

    }

    @ViewBuilder
    private func accountLink(title: String,
                             subtitle: String? = nil,
                             systemImage: String,
                             action: @escaping () -> Void) -> some View {

        HStack(spacing: self.style.spacing(.medium)) {

            ImageSource.systemImage(systemImage)
                .view(shouldResize: false)
                .appFont(with: .TITLE_6)
                .foregroundStyle(self.style.textColor(.title))
                .frame(width: self.style.spacing(.large2))

            VStack(alignment: .leading, spacing: self.style.spacing(.extraSmall)) {

                Text(title)
                    .appFont(with: .TITLE_3)
                    .foregroundStyle(self.style.textColor(.title))

                if let subtitle {

                    Text(subtitle)
                        .appFont(with: .BODY_1)
                        .foregroundStyle(self.style.textColor(.body))

                }

            }
            .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)

            ImageSource.systemImage("chevron.right")
                .view(shouldResize: false)
                .appFont(with: .TITLE_1)
                .foregroundStyle(self.style.textColor(.placeholder))

        }
        .padding(.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .asButton(action: action)

    }

}
