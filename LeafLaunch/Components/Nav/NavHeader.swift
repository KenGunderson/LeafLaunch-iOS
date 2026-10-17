//
//  NavHeader.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 8/13/25.
//

import SwiftUI

struct NavHeader: View {

    @Environment(\.style) private var style

    private let title: String
    private let subtitle: String?
    private let subtitleAction: (() -> Void)?
    private let leadingImage: ImageSource?
    private let showLogo: Bool
    private let backgroundStyle: ColorSource
    private let leadingNavButtons: [NavBarButton.Style]
    private let leadingNavButtonsAction: ((NavBarButton.Style) -> Void)?
    private let trailingNavButtons: [NavBarButton.Style]
    private let trailingNavButtonsForegroundColor: ColorSource
    private let trailingNavButtonsAction: ((NavBarButton.Style) -> Void)?

    init(title: String,
         subtitle: String? = nil,
         subtitleAction: (() -> Void)? = nil,
         leadingImage: ImageSource? = nil,
         showLogo: Bool = false,
         backgroundStyle: ColorSource = .background(.primary),
         leadingNavButtons: [NavBarButton.Style] = [],
         leadingNavButtonsAction: ((NavBarButton.Style) -> Void)? = nil,
         trailingNavButtons: [NavBarButton.Style] = [],
         trailingNavButtonsForegroundColor: ColorSource = .text(.title),
         trailingNavButtonsAction: ((NavBarButton.Style) -> Void)? = nil) {

        self.title = title
        self.subtitle = subtitle
        self.subtitleAction = subtitleAction
        self.leadingImage = leadingImage
        self.showLogo = showLogo
        self.backgroundStyle = backgroundStyle
        self.leadingNavButtons = leadingNavButtons
        self.leadingNavButtonsAction = leadingNavButtonsAction
        self.trailingNavButtons = trailingNavButtons
        self.trailingNavButtonsForegroundColor = trailingNavButtonsForegroundColor
        self.trailingNavButtonsAction = trailingNavButtonsAction

    }

    var body: some View {

        HStack(spacing: self.style.spacing(.small2)) {

            if !self.leadingNavButtons.isEmpty {

                navButtons(
                    self.leadingNavButtons,
                    action: self.leadingNavButtonsAction
                )

            }

            if self.showLogo {

                ImageSource.image(ImageResource(name: BusinessConfig.logoAssetName, bundle: .main))
                    .view()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: self.style.spacing(.large2))
                    .frame(maxWidth: .infinity, alignment: .leading)

            } else {

                if let leadingImage = self.leadingImage {
                    brandImage(leadingImage)
                }

                titleSubtitleView()

            }

            if !self.trailingNavButtons.isEmpty {

                navButtons(
                    self.trailingNavButtons,
                    foregroundColor: self.trailingNavButtonsForegroundColor,
                    action: self.trailingNavButtonsAction
                )

            }

        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, .medium)
        .background(self.backgroundStyle)
        .background {

            Rectangle()
                .fill(self.backgroundStyle)
                .blur(radius: 2)
                .offset(y: 10)

        }

    }

    @ViewBuilder
    private func brandImage(_ image: ImageSource) -> some View {

        self.style.background(.tertiary).view()
            .frame(width: self.style.spacing(.extraLarge), height: self.style.spacing(.extraLarge))
            .overlay {

                image.view()
                    .aspectRatio(contentMode: .fill)

            }
            .clipped()
            .cornerRadius(.medium2)

    }

    @ViewBuilder
    private func titleSubtitleView() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.extraSmall)) {

            Text(self.title)
                .appFont(with: .HEADER_3)
                .foregroundStyle(.text(.title))

            if let subtitle = self.subtitle {

                subtitleView(subtitle)

            }

        }
        .frame(maxWidth: .infinity, alignment: .leading)

    }

    @ViewBuilder
    private func subtitleView(_ subtitle: String) -> some View {

        if let subtitleAction = self.subtitleAction {

            HStack(alignment: .center, spacing: self.style.spacing(.extraSmall)) {

                Text(subtitle)
                    .fixedSize(horizontal: false, vertical: true)
                ImageSource.systemImage("chevron.down")
                    .view(shouldResize: false)

            }
            .appFont(with: .BODY_1)
            .foregroundStyle(.text(.body))
            .contentShape(Rectangle())
            .asButton(action: subtitleAction)

        } else {

            Text(subtitle)
                .appFont(with: .BODY_1)
                .foregroundStyle(.text(.body))
                .fixedSize(horizontal: false, vertical: true)

        }

    }

    @ViewBuilder
    private func navButtons(_ buttons: [NavBarButton.Style],
                            foregroundColor: ColorSource = .text(.title),
                            action: ((NavBarButton.Style) -> Void)? = nil) -> some View {

        HStack(spacing: self.style.spacing(.small)) {

            ForEach(buttons, id: \.self) { navStyle in

                NavBarButton(style: navStyle, foregroundColor: foregroundColor) {
                    action?(navStyle)
                }

            }

        }

    }

}

#Preview {

    AppBaseView {

        VStack(spacing: 32) {

            NavHeader(
                title: "Good Morning, Sako",
                subtitle: "Select where you're working today",
                showLogo: true,
                trailingNavButtons: [
                    .bell(notificationCount: 1),
                    .settings
                ]
            ) { navItem in
                print(navItem)
            }

            NavHeader(
                title: "Good Morning, Sako",
                subtitle: "Select where you're working today",
                leadingNavButtons: [.back],
                leadingNavButtonsAction: { _ in }
            )

            NavHeader(
                title: "Good Morning, Sako",
                subtitle: "Select where you're working today"
            )

            NavHeader(
                title: "Good Morning, Sako",
                subtitle: "Select where you're working today",
                trailingNavButtons: [.plus]
            )

        }
        .padding(.horizontal, .medium)

    }

}

#Preview {

    AppHeaderScrollView(navBarContent: {

        NavHeader(
            title: "Good Morning, Sako",
            subtitle: "Select where you're working today",
            showLogo: true,
            trailingNavButtons: [
                .bell(notificationCount: 1),
                .settings
            ]
        ) { navItem in
            print(navItem)
        }

    }, scrollViewContent: {

        VStack(spacing: 24) {

            RoundedRectangle(cornerRadius: 16)
                .fill(.red)
                .frame(height: 120)

            RoundedRectangle(cornerRadius: 16)
                .fill(.red)
                .frame(height: 120)

            RoundedRectangle(cornerRadius: 16)
                .fill(.red)
                .frame(height: 120)

            RoundedRectangle(cornerRadius: 16)
                .fill(.red)
                .frame(height: 120)

        }

    })

}
