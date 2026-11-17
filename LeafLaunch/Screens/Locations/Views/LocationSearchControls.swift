//
//  LocationSearchControls.swift
//  LeafLaunch
//
//  Created by KC Gunderson on 10/17/26.
//

import SwiftUI

struct LocationSearchControls: View {

    @Environment(\.style) private var style

    @ObservedObject var viewModel: LocationListViewModel

    @FocusState private var isSearchFocused: Bool

    var body: some View {

        ViewThatFits(in: .horizontal) {

            HStack(spacing: self.style.spacing(LLSpacing.cardContent)) {

                searchField()
                    .frame(minWidth: 180)
                locationButton()

            }

            VStack(spacing: self.style.spacing(LLSpacing.cardContent)) {

                searchField()
                locationButton()

            }

        }
        .disabled(self.viewModel.isContinuing)

    }

    @ContentBuilder
    private func searchField() -> some View {

        HStack(spacing: self.style.spacing(LLSpacing.groupedContent)) {

            RNImageSource.systemImage("magnifyingglass")
                .view(shouldResize: false)
                .runeTextColor(.placeholder)

            TextField(
                String(localized: "City Or ZIP Code"),
                text: self.$viewModel.search
            )
                .runeFont(with: .BODY_1)
                .runeTextColor(.title)
                .focused(self.$isSearchFocused)
                .submitLabel(.search)
                .autocorrectionDisabled()
                .onSubmit {

                    self.isSearchFocused = false
                    self.viewModel.submitSearch()

                }

            if self.viewModel.isSearchingNearby {

                ProgressView()
                    .tint(RNColorSource.palette(.link))

            }

            if !self.viewModel.search.isEmpty {

                RNImageSource.systemImage("xmark.circle.fill")
                    .view(shouldResize: false)
                    .runeTextColor(.body)
                    .frame(
                        minWidth: 44,
                        minHeight: 44
                    )
                    .contentShape(Rectangle())
                    .runeAsButton {

                        self.viewModel.clearSearch()
                        self.isSearchFocused = true

                    }

            }

        }
        .runePadding(.horizontal, LLSpacing.cardContent)
        .frame(minHeight: 56)
        .runeBackground(.secondary)
        .runeCornerRadius(.medium2)
        .overlay {

            RoundedRectangle(cornerRadius: self.style.radius(.medium2))
                .strokeBorder(
                    self.isSearchFocused ? RNColorSource.palette(.link) : RNColorSource.background(.border),
                    lineWidth: 1
                )
                .allowsHitTesting(false)

        }

    }

    @ContentBuilder
    private func locationButton() -> some View {

        HStack(spacing: self.style.spacing(LLSpacing.groupedContent)) {

            locationButtonIcon()

            Text(String(localized: "Use My\nLocation"))
                .runeFont(with: .TITLE_1)
                .runeTextColor(.title)
                .fixedSize(
                    horizontal: true,
                    vertical: true
                )
                .multilineTextAlignment(.leading)

        }
        .runePadding(.horizontal, LLSpacing.cardContent)
        .frame(minHeight: 56)
        .runeBackground(.secondary)
        .runeCornerRadius(.medium2)
        .runeBorder(
            cornerRadius: .medium2,
            lineWidth: 1
        )
        .contentShape(Rectangle())
        .runeAsButton {

            self.isSearchFocused = false
            self.viewModel.useCurrentLocation()

        }
        .disabled(self.viewModel.isLocating)

    }

    @ContentBuilder
    private func locationButtonIcon() -> some View {

        ZStack {

            if self.viewModel.isLocating {

                ProgressView()
                    .tint(RNColorSource.palette(.link))

            } else {

                RNImageSource.systemImage("location")
                    .view(shouldResize: false)
                    .runeFont(with: .TITLE_5)
                    .foregroundStyle(RNColorSource.palette(.link))

            }

        }
        .frame(
            width: self.style.spacing(.large),
            height: self.style.spacing(.large)
        )

    }

}
