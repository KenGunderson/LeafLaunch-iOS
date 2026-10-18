//
//  LocationSearchControls.swift
//  LeafLaunch
//
//  Created by KC Gunderson on 10/17/26.
//

import SwiftUI

struct LocationSearchControls: View {

    @Environment(\.style) private var style

    @ObservedObject var viewModel: LocationsViewModel

    @FocusState private var isSearchFocused: Bool

    var body: some View {

        ViewThatFits(in: .horizontal) {

            HStack(spacing: self.style.spacing(.small2)) {

                searchField()
                    .frame(minWidth: 180)
                locationButton()

            }

            VStack(spacing: self.style.spacing(.small2)) {

                searchField()
                locationButton()

            }

        }
        .disabled(self.viewModel.isContinuing)

    }

    @ViewBuilder
    private func searchField() -> some View {

        HStack(spacing: self.style.spacing(.small)) {

            ImageSource.systemImage("magnifyingglass")
                .view(shouldResize: false)
                .foregroundStyle(self.style.textColor(.placeholder))

            TextField(String(localized: "City or ZIP code"), text: self.$viewModel.search)
                .appFont(with: .BODY_1)
                .foregroundStyle(self.style.textColor(.title))
                .focused(self.$isSearchFocused)
                .submitLabel(.search)
                .autocorrectionDisabled()
                .onSubmit { self.isSearchFocused = false }

            if !self.viewModel.search.isEmpty {

                ImageSource.systemImage("xmark.circle.fill")
                    .view(shouldResize: false)
                    .foregroundStyle(self.style.textColor(.body))
                    .frame(minWidth: 44, minHeight: 44)
                    .contentShape(Rectangle())
                    .asButton {

                        self.viewModel.clearSearch()
                        self.isSearchFocused = true

                    }

            }

        }
        .padding(.horizontal, .small2)
        .frame(minHeight: 56)
        .background(self.style.background(.secondary))
        .clipShape(RoundedRectangle(cornerRadius: self.style.radius(.medium2)))
        .overlay {

            RoundedRectangle(cornerRadius: self.style.radius(.medium2))
                .strokeBorder(self.isSearchFocused ? self.style.palette(.link) : self.style.background(.border), lineWidth: 1)
                .allowsHitTesting(false)

        }

    }

    @ViewBuilder
    private func locationButton() -> some View {

        HStack(spacing: self.style.spacing(.small)) {

            locationButtonIcon()

            Text(String(localized: "Use My\nLocation"))
                .appFont(with: .TITLE_1)
                .foregroundStyle(self.style.textColor(.title))
                .fixedSize(horizontal: true, vertical: true)
                .multilineTextAlignment(.leading)

        }
        .padding(.horizontal, .small2)
        .frame(minHeight: 56)
        .background(self.style.background(.secondary))
        .clipShape(RoundedRectangle(cornerRadius: self.style.radius(.medium2)))
        .appBorder(cornerRadius: .medium2, lineWidth: 1)
        .contentShape(Rectangle())
        .asButton {

            self.isSearchFocused = false
            self.viewModel.useCurrentLocation()

        }
        .disabled(self.viewModel.isLocating)

    }

    @ViewBuilder
    private func locationButtonIcon() -> some View {

        ZStack {

            if self.viewModel.isLocating {

                ProgressView()
                    .tint(self.style.palette(.link))

            } else {

                ImageSource.systemImage("location")
                    .view(shouldResize: false)
                    .appFont(with: .TITLE_5)
                    .foregroundStyle(self.style.palette(.link))

            }

        }
        .frame(width: self.style.spacing(.large), height: self.style.spacing(.large))

    }

}
