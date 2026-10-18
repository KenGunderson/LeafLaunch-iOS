//
//  LocationSelectionFooter.swift
//  LeafLaunch
//
//  Created by KC Gunderson on 10/17/26.
//

import SwiftUI

struct LocationSelectionFooter: View {

    @Environment(\.style) private var style

    let isEnabled: Bool
    let continueAction: () -> Void

    var body: some View {

        LeafLaunchButton(
            title: String(localized: "Continue"),
            icon: .systemImage("chevron.right"),
            iconAlignment: .trailing,
            size: .prominent,
            isEnabled: self.isEnabled,
            action: self.continueAction
        )
        .padding(.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(self.style.background(.secondary))
        .overlay(alignment: .top) {
            LLDivider()
        }

    }

}
