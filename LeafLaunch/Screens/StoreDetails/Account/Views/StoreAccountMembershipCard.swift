//
//  StoreAccountMembershipCard.swift
//  LeafLaunch
//
//  Created by KC Gunderson on 10/17/26.
//

import SwiftUI

struct StoreAccountMembershipCard: View {

    @Environment(\.style) private var style

    let account: CustomerAccount
    let detailsAction: () -> Void

    private var businessInitials: String {
        return self.account.storeName.split(whereSeparator: { $0.isWhitespace }).prefix(2).compactMap(\.first).map(String.init).joined()
    }

    private var pointsBalance: String {

        guard let points = Int64(self.account.cachedPointsBalance) else { return self.account.cachedPointsBalance }
        return points.formatted()

    }

    private var statusDescription: String {

        switch self.account.status {
        case .active: return String(localized: "Active Member")
        case .suspended: return String(localized: "Membership Suspended")
        case .banned: return String(localized: "Membership Unavailable")
        case .anonymized: return String(localized: "Membership Anonymized")
        }

    }

    var body: some View {

        LLAppCardView(
            verticalPadding: .none,
            horizontalPadding: .none,
            backgroundStyle: .color(.clear),
            cornerRadius: .large
        ) {

            VStack(
                alignment: .leading,
                spacing: self.style.spacing(LLSpacing.listRow)
            ) {

                membershipHeader()
                points()
                membershipFooter()

            }
            .runePadding(.medium2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background { cardBackground() }

        }
        .foregroundStyle(Color.white)

    }

    @ContentBuilder
    private func membershipHeader() -> some View {

        ViewThatFits(in: .horizontal) {

            HStack(spacing: self.style.spacing(LLSpacing.listRow)) {

                businessIdentity()
                    .frame(maxWidth: .infinity, alignment: .leading)
                membershipStatus()

            }

            VStack(
                alignment: .leading,
                spacing: self.style.spacing(LLSpacing.cardContent)
            ) {

                businessIdentity()
                membershipStatus()

            }

        }

    }

    @ContentBuilder
    private func businessIdentity() -> some View {

        HStack(spacing: self.style.spacing(LLSpacing.cardContent)) {

            Text(self.businessInitials)
                .runeFont(with: .TITLE_3)
                .runeTextColor(.titleInverted)
                .frame(
                    width: self.style.spacing(.large2),
                    height: self.style.spacing(.large2)
                )
                .background(RNColorSource.palette(.link))
                .runeCornerRadius(.medium)

            Text(self.account.storeName)
                .runeFont(with: .TITLE_3)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )

        }

    }

    @ContentBuilder
    private func membershipStatus() -> some View {

        HStack(spacing: self.style.spacing(LLSpacing.groupedContent)) {

            Circle()
                .runeFill(self.account.status == .active ? RNColorSource.palette(.success) : RNColorSource.palette(.warning))
                .frame(
                    width: self.style.spacing(.small),
                    height: self.style.spacing(.small)
                )

            Text(self.statusDescription)
                .runeFont(with: .TITLE_1)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )

        }

    }

    @ContentBuilder
    private func points() -> some View {

        VStack(
            alignment: .leading,
            spacing: self.style.spacing(LLSpacing.none)
        ) {

            Text(self.pointsBalance)
                .runeFont(with: .BILLBOARD_3)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.5)

            Text(self.account.status == .active ? String(localized: "Points Available") : String(localized: "Points Balance"))
                .runeFont(with: .BODY_2)

        }
        .frame(maxWidth: .infinity, alignment: .leading)

    }

    @ContentBuilder
    private func membershipFooter() -> some View {

        VStack(spacing: self.style.spacing(LLSpacing.cardContent)) {

            Rectangle()
                .runeFill(.color(.white.opacity(0.24)))
                .frame(height: 1)

            ViewThatFits(in: .horizontal) {

                HStack(spacing: self.style.spacing(LLSpacing.listRow)) {

                    memberCode()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    detailsButton()

                }

                VStack(
                    alignment: .leading,
                    spacing: self.style.spacing(LLSpacing.cardContent)
                ) {

                    memberCode()
                    detailsButton()

                }
                .frame(maxWidth: .infinity, alignment: .leading)

            }

        }

    }

    @ContentBuilder
    private func memberCode() -> some View {

        if !self.account.membershipCode.isEmpty {

            VStack(
                alignment: .leading,
                spacing: self.style.spacing(LLSpacing.metadata)
            ) {

                Text(String(localized: "Member ID"))
                    .runeFont(with: .NOTE_1)
                    .foregroundStyle(Color.white.opacity(0.72))

                Text(self.account.membershipCode)
                    .runeFont(with: .TITLE_3)
                    .textSelection(.enabled)

            }

        }

    }

    @ContentBuilder
    private func detailsButton() -> some View {

        HStack(spacing: self.style.spacing(LLSpacing.cardContent)) {

            Text(String(localized: "View Membership"))
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )
            RNImageSource.systemImage("chevron.right").view(shouldResize: false)

        }
        .runeFont(with: .TITLE_1)
        .frame(minHeight: 44)
        .contentShape(Rectangle())
        .runeAsButton(action: self.detailsAction)

    }

    @ContentBuilder
    private func cardBackground() -> some View {

        // The base keeps 22% of the active accent; the accent plane raises that
        // to 40.72%, and the lower plane adds 4% white over either accent tone.
        RNColorSource.palette(.link).view()
            .overlay(Color.black.opacity(0.78))
            .overlay {

                GeometryReader { geometry in

                    Path { path in

                        path.move(to: CGPoint(
                            x: geometry.size.width * 0.76,
                            y: 0
                        ))
                        path.addLine(to: CGPoint(
                            x: geometry.size.width,
                            y: 0
                        ))
                        path.addLine(to: CGPoint(
                            x: geometry.size.width,
                            y: geometry.size.height * 0.60
                        ))
                        path.addLine(to: CGPoint(
                            x: geometry.size.width * 0.90,
                            y: geometry.size.height * 0.72
                        ))
                        path.closeSubpath()

                    }
                    .runeFill(RNColorSource.palette(.link))
                    .opacity(0.24)

                    Path { path in

                        path.move(to: CGPoint(
                            x: geometry.size.width * 0.35,
                            y: geometry.size.height
                        ))
                        path.addLine(to: CGPoint(
                            x: geometry.size.width,
                            y: geometry.size.height * 0.60
                        ))
                        path.addLine(to: CGPoint(
                            x: geometry.size.width,
                            y: geometry.size.height
                        ))
                        path.closeSubpath()

                    }
                    .runeFill(.color(.white.opacity(0.04)))

                }

            }
            .allowsHitTesting(false)

    }

}
