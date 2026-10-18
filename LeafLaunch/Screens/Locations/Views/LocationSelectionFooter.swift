//
//  LocationSelectionFooter.swift
//  LeafLaunch
//
//  Created by KC Gunderson on 10/17/26.
//

import SwiftUI

struct LocationSelectionFooter: View {

    @Environment(\.style) private var style

    let selectedLocationName: String?
    let isEnabled: Bool
    let continueAction: () -> Void

    var body: some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.medium)) {

            selectionSummary()

            LeafLaunchButton(
                title: String(localized: "Continue"),
                icon: .systemImage("chevron.right"),
                iconAlignment: .trailing,
                size: .prominent,
                isEnabled: self.isEnabled,
                action: self.continueAction
            )

        }
        .padding(.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(self.style.background(.secondary))
        .overlay(alignment: .top) {
            Divider().overlay(self.style.background(.border))
        }

    }

    @ViewBuilder
    private func selectionSummary() -> some View {

        if let selectedLocationName = self.selectedLocationName {

            Text("\(String(localized: "Selected:")) \(Text(selectedLocationName).bold().foregroundStyle(self.style.textColor(.title)))")
                .appFont(with: .BODY_1)
                .foregroundStyle(self.style.textColor(.body))
                .fixedSize(horizontal: false, vertical: true)

        } else {

            Text(String(localized: "Select a store to continue."))
                .appFont(with: .BODY_1)
                .foregroundStyle(self.style.textColor(.body))

        }

    }

}
