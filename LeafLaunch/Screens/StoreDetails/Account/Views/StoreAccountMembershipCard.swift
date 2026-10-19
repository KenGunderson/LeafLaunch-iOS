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
        case .active: return String(localized: "Active member")
        case .suspended: return String(localized: "Membership suspended")
        case .banned: return String(localized: "Membership unavailable")
        case .anonymized: return String(localized: "Membership anonymized")
        }

    }

    var body: some View {

        LLAppCardView(
            verticalPadding: .none,
            horizontalPadding: .none,
            backgroundStyle: .color(.clear),
            cornerRadius: .large
        ) {

            VStack(alignment: .leading, spacing: self.style.spacing(.medium)) {

                membershipHeader()
                points()
                membershipFooter()

            }
            .padding(.medium2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background { cardBackground() }

        }
        .foregroundStyle(Color.white)

    }

    @ViewBuilder
    private func membershipHeader() -> some View {

        ViewThatFits(in: .horizontal) {

            HStack(spacing: self.style.spacing(.medium)) {

                businessIdentity()
                    .frame(maxWidth: .infinity, alignment: .leading)
                membershipStatus()

            }

            VStack(alignment: .leading, spacing: self.style.spacing(.small2)) {

                businessIdentity()
                membershipStatus()

            }

        }

    }

    @ViewBuilder
    private func businessIdentity() -> some View {

        HStack(spacing: self.style.spacing(.small2)) {

            Text(self.businessInitials)
                .appFont(with: .TITLE_3)
                .foregroundStyle(self.style.textColor(.titleInverted))
                .frame(width: self.style.spacing(.large2), height: self.style.spacing(.large2))
                .background(self.style.palette(.link))
                .clipShape(RoundedRectangle(cornerRadius: self.style.radius(.medium)))

            Text(self.account.storeName)
                .appFont(with: .TITLE_3)
                .fixedSize(horizontal: false, vertical: true)

        }

    }

    @ViewBuilder
    private func membershipStatus() -> some View {

        HStack(spacing: self.style.spacing(.small)) {

            Circle()
                .fill(self.account.status == .active ? self.style.palette(.success) : self.style.palette(.warning))
                .frame(width: self.style.spacing(.small), height: self.style.spacing(.small))

            Text(self.statusDescription)
                .appFont(with: .TITLE_1)
                .fixedSize(horizontal: false, vertical: true)

        }

    }

    @ViewBuilder
    private func points() -> some View {

        VStack(alignment: .leading, spacing: 0) {

            Text(self.pointsBalance)
                .appFont(with: .BILLBOARD_3)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.5)

            Text(self.account.status == .active ? String(localized: "Points Available") : String(localized: "Points Balance"))
                .appFont(with: .BODY_2)

        }
        .frame(maxWidth: .infinity, alignment: .leading)

    }

    @ViewBuilder
    private func membershipFooter() -> some View {

        VStack(spacing: self.style.spacing(.small2)) {

            Rectangle()
                .fill(Color.white.opacity(0.24))
                .frame(height: 1)

            ViewThatFits(in: .horizontal) {

                HStack(spacing: self.style.spacing(.medium)) {

                    memberCode()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    detailsButton()

                }

                VStack(alignment: .leading, spacing: self.style.spacing(.small2)) {

                    memberCode()
                    detailsButton()

                }
                .frame(maxWidth: .infinity, alignment: .leading)

            }

        }

    }

    @ViewBuilder
    private func memberCode() -> some View {

        if !self.account.membershipCode.isEmpty {

            VStack(alignment: .leading, spacing: self.style.spacing(.extraSmall)) {

                Text(String(localized: "Member ID"))
                    .appFont(with: .NOTE_1)
                    .foregroundStyle(Color.white.opacity(0.72))

                Text(self.account.membershipCode)
                    .appFont(with: .TITLE_3)
                    .textSelection(.enabled)

            }

        }

    }

    @ViewBuilder
    private func detailsButton() -> some View {

        HStack(spacing: self.style.spacing(.small2)) {

            Text(String(localized: "View Membership"))
                .fixedSize(horizontal: false, vertical: true)
            ImageSource.systemImage("chevron.right").view(shouldResize: false)

        }
        .appFont(with: .TITLE_1)
        .frame(minHeight: 44)
        .contentShape(Rectangle())
        .asButton(action: self.detailsAction)

    }

    @ViewBuilder
    private func cardBackground() -> some View {

        // The base keeps 22% of the active accent; the accent plane raises that
        // to 40.72%, and the lower plane adds 4% white over either accent tone.
        self.style.palette(.link).view()
            .overlay(Color.black.opacity(0.78))
            .overlay {

                GeometryReader { geometry in

                    Path { path in

                        path.move(to: CGPoint(x: geometry.size.width * 0.76, y: 0))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: 0))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height * 0.60))
                        path.addLine(to: CGPoint(x: geometry.size.width * 0.90, y: geometry.size.height * 0.72))
                        path.closeSubpath()

                    }
                    .fill(self.style.palette(.link))
                    .opacity(0.24)

                    Path { path in

                        path.move(to: CGPoint(x: geometry.size.width * 0.35, y: geometry.size.height))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height * 0.60))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height))
                        path.closeSubpath()

                    }
                    .fill(Color.white.opacity(0.04))

                }

            }
            .allowsHitTesting(false)

    }

}
