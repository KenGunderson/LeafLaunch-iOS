//
//  StoreAccountMembershipDetailsView.swift
//  LeafLaunch
//
//  Created by KC Gunderson on 10/17/26.
//

import SwiftUI

struct StoreAccountMembershipDetailsView: View {

    @Environment(\.style) private var style
    @Environment(\.dismiss) private var dismiss

    let account: CustomerAccount
    let membership: CustomerLocationMembership?
    let locationName: String?

    private var locationStatus: String {

        switch self.membership?.status {
        case .active: return String(localized: "Enabled")
        case .left: return String(localized: "Left Location")
        case .anonymized: return String(localized: "Anonymized")
        case nil: return String(localized: "Not Enabled")
        }

    }

    var body: some View {

        LLAppHeaderScrollView {
            navHeader()
        } scrollViewContent: {
            content()
        }
        .safeAreaInset(edge: .bottom) {

            LeafLaunchButton(title: String(localized: "Done")) { self.dismiss() }
                .runePadding(LLSpacing.pageInset)

        }

    }

    @ContentBuilder
    private func navHeader() -> some View {

        NavHeader(
            title: String(localized: "Membership"),
            trailingNavButtons: [.close],
            trailingNavButtonsAction: { _ in self.dismiss() }
        )
        .safeAreaPadding(
            .top,
            self.style.spacing(LLSpacing.listRow)
        )

    }

    @ContentBuilder
    private func content() -> some View {

        VStack(
            alignment: .leading,
            spacing: self.style.spacing(LLSpacing.content)
        ) {

            CommerceSurface {

                VStack(
                    alignment: .leading,
                    spacing: self.style.spacing(LLSpacing.listRow)
                ) {

                    detail(
                        String(localized: "Business"),
                        value: self.account.storeName
                    )
                    detail(
                        String(localized: "Member Name"),
                        value: self.account.displayName
                    )
                    detail(
                        String(localized: "Member ID"),
                        value: self.account.membershipCode
                    )
                    detail(
                        String(localized: "Points Balance"),
                        value: self.account.cachedPointsBalance
                    )
                    detail(
                        String(localized: "Member Since"),
                        value: self.account.createdAt.formatted(
                            date: .abbreviated,
                            time: .omitted
                        )
                    )

                }

            }

            if let locationName = self.locationName {

                CommerceSurface {

                    VStack(
                        alignment: .leading,
                        spacing: self.style.spacing(LLSpacing.listRow)
                    ) {

                        detail(
                            String(localized: "Your Store"),
                            value: locationName
                        )
                        detail(
                            String(localized: "Location Activity"),
                            value: self.locationStatus
                        )

                    }

                }

            }

        }
        .runePadding(.bottom, LLSpacing.content)

    }

    @ContentBuilder
    private func detail(_ title: String, value: String) -> some View {

        if !value.isEmpty {

            VStack(
                alignment: .leading,
                spacing: self.style.spacing(LLSpacing.metadata)
            ) {

                Text(title)
                    .runeFont(with: .NOTE_1)
                    .runeTextColor(.body)

                Text(value)
                    .runeFont(with: .TITLE_3)
                    .runeTextColor(.title)
                    .textSelection(.enabled)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )

            }

        }

    }

}
