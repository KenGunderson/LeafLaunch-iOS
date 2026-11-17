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
    private let status: String?
    private let statusColor: RNColorSource
    private let leadingImage: RNImageSource?
    private let showLogo: Bool
    private let backgroundStyle: RNColorSource
    private let leadingNavButtons: [NavBarButton.Style]
    private let leadingNavButtonsAction: ((NavBarButton.Style) -> Void)?
    private let trailingNavButtons: [NavBarButton.Style]
    private let trailingNavButtonsForegroundColor: RNColorSource
    private let trailingNavButtonsAction: ((NavBarButton.Style) -> Void)?

    init(title: String,
         subtitle: String? = nil,
         subtitleAction: (() -> Void)? = nil,
         status: String? = nil,
         statusColor: RNColorSource = .palette(.link),
         leadingImage: RNImageSource? = nil,
         showLogo: Bool = false,
         backgroundStyle: RNColorSource = .background(.primary),
         leadingNavButtons: [NavBarButton.Style] = [],
         leadingNavButtonsAction: ((NavBarButton.Style) -> Void)? = nil,
         trailingNavButtons: [NavBarButton.Style] = [],
         trailingNavButtonsForegroundColor: RNColorSource = .text(.title),
         trailingNavButtonsAction: ((NavBarButton.Style) -> Void)? = nil) {

        self.title = title
        self.subtitle = subtitle
        self.subtitleAction = subtitleAction
        self.status = status
        self.statusColor = statusColor
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

        HStack(spacing: self.style.spacing(LLSpacing.section)) {

            if !self.leadingNavButtons.isEmpty {

                navButtons(
                    self.leadingNavButtons,
                    action: self.leadingNavButtonsAction
                )

            }

            if self.showLogo {

                RNImageSource.image(ImageResource(
                    name: BusinessConfig.logoAssetName,
                    bundle: .main
                ))
                    .view()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 32)
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
        .runePadding(.horizontal, LLSpacing.pageInset)
        .background(self.backgroundStyle)
        .background {

            Rectangle()
                .runeFill(self.backgroundStyle)
                .blur(radius: 2)
                .offset(y: 10)

        }

    }

    @ContentBuilder
    private func brandImage(_ image: RNImageSource) -> some View {

        Rectangle()
            .runeFill(.background(.tertiary))
            .frame(
                width: 40,
                height: 40
            )
            .overlay {

                image.view()
                    .aspectRatio(contentMode: .fill)

            }
            .clipped()
            .runeCornerRadius(.medium2)

    }

    @ContentBuilder
    private func titleSubtitleView() -> some View {

        VStack(
            alignment: .leading,
            spacing: self.style.spacing(LLSpacing.none)
        ) {

            Text(self.title)
                .runeFont(with: LeafLaunchThemeTokens.headingFont)
                .runeTextColor(.title)

            if let subtitle = self.subtitle {

                subtitleView(subtitle)

            }

            if let status = self.status {
                statusView(status)
            }

        }
        .frame(maxWidth: .infinity, alignment: .leading)

    }

    @ContentBuilder
    private func statusView(_ status: String) -> some View {

        HStack(spacing: self.style.spacing(LLSpacing.metadata)) {

            Circle()
                .runeFill(self.statusColor)
                .frame(
                    width: 8,
                    height: 8
                )

            Text(status)
                .runeFont(with: .BODY_1)
                .runeTextColor(.body)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )

        }

    }

    @ContentBuilder
    private func subtitleView(_ subtitle: String) -> some View {

        if let subtitleAction = self.subtitleAction {

            HStack(
                alignment: .center,
                spacing: self.style.spacing(LLSpacing.metadata)
            ) {

                Text(subtitle)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
                RNImageSource.systemImage("chevron.down")
                    .view(shouldResize: false)

            }
            .runeFont(with: .BODY_1)
            .runeTextColor(.body)
            .contentShape(Rectangle())
            .runeAsButton(action: subtitleAction)

        } else {

            Text(subtitle)
                .runeFont(with: .BODY_1)
                .runeTextColor(.body)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )

        }

    }

    @ContentBuilder
    private func navButtons(_ buttons: [NavBarButton.Style],
                            foregroundColor: RNColorSource = .text(.title),
                            action: ((NavBarButton.Style) -> Void)? = nil) -> some View {

        HStack(spacing: self.style.spacing(LLSpacing.groupedContent)) {

            ForEach(buttons, id: \.self) { navStyle in

                NavBarButton(
                    style: navStyle,
                    foregroundColor: foregroundColor
                ) {
                    action?(navStyle)
                }

            }

        }

    }

}

#Preview {

    @Previewable @Environment(\.style) var style

    RNBaseView {

        VStack(spacing: style.spacing(LLSpacing.hero)) {

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
        .runePadding(.horizontal, LLSpacing.pageInset)

    }

}

#Preview {

    @Previewable @Environment(\.style) var style

    RNHeaderScrollView(
        navBarContent: {

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

        },
        scrollViewContent: {

            VStack(spacing: style.spacing(LLSpacing.content)) {

                RoundedRectangle(cornerRadius: style.radius(.custom(16)))
                    .runeFill(.color(.red))
                    .frame(height: 120)

                RoundedRectangle(cornerRadius: style.radius(.custom(16)))
                    .runeFill(.color(.red))
                    .frame(height: 120)

                RoundedRectangle(cornerRadius: style.radius(.custom(16)))
                    .runeFill(.color(.red))
                    .frame(height: 120)

                RoundedRectangle(cornerRadius: style.radius(.custom(16)))
                    .runeFill(.color(.red))
                    .frame(height: 120)

            }

        }
    )

}
