//
//  Section.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 8/20/25.
//

import SwiftUI

struct SectionView<Trailing: View>: View {

    @Environment(\.style) private var style

    let leadingTitle: String
    let leadingForegroundColor: RNColorSource
    let showDivider: Bool
    let dividerLineWidth: CGFloat
    let trailingTitle: String
    let trailingAction: (() -> Void)?
    let trailingView: Trailing?
    let titleFont: RNTheme.FontKey

    init(leadingTitle: String,
         leadingForegroundColor: RNColorSource = .text(.title),
         showDivider: Bool = false,
         dividerLineWidth: CGFloat = 1.5,
         trailingTitle: String = "View All",
         trailingAction: (() -> Void)? = nil,
         titleFont: RNTheme.FontKey = LeafLaunchThemeTokens.headingFont,
         @ContentBuilder trailingView: () -> Trailing) {

        self.leadingTitle = leadingTitle
        self.leadingForegroundColor = leadingForegroundColor
        self.showDivider = showDivider
        self.dividerLineWidth = dividerLineWidth
        self.trailingTitle = trailingTitle
        self.trailingAction = trailingAction
        self.trailingView = trailingView()
        self.titleFont = titleFont

    }

    private init(leadingTitle: String,
                 leadingForegroundColor: RNColorSource,
                 showDivider: Bool,
                 dividerLineWidth: CGFloat,
                 trailingTitle: String,
                 trailingAction: (() -> Void)?,
                 trailingView: Trailing?,
                 titleFont: RNTheme.FontKey) {

        self.leadingTitle = leadingTitle
        self.leadingForegroundColor = leadingForegroundColor
        self.showDivider = showDivider
        self.dividerLineWidth = dividerLineWidth
        self.trailingTitle = trailingTitle
        self.trailingAction = trailingAction
        self.trailingView = trailingView
        self.titleFont = titleFont

    }

    var body: some View {

        VStack(
            alignment: .leading,
            spacing: self.style.spacing(LLSpacing.metadata)
        ) {

            HStack(spacing: self.style.spacing(LLSpacing.groupedContent)) {

                Text(self.leadingTitle)
                    .runeFont(with: self.titleFont)
                    .foregroundStyle(self.leadingForegroundColor)
                    .frame(maxWidth: .infinity, alignment: .leading)

                self.trailingContent

            }

            if self.showDivider {

                Capsule()
                    .runeFill(.background(.quaternary))
                    .frame(height: self.dividerLineWidth)

            }

        }

    }

    @ContentBuilder
    private var trailingContent: some View {

        if let trailingView = self.trailingView {

            trailingView

        } else if let trailingAction = self.trailingAction {

            HStack(spacing: self.style.spacing(LLSpacing.groupedContent)) {

                Text(self.trailingTitle)
                    .runeFont(with: .BODY_2)

                RNImageSource.systemImage("arrow.right")
                    .view()
                    .aspectRatio(contentMode: .fit)
                    .frame(
                        width: 12,
                        height: 12
                    )

            }
            .runeTextColor(.body)
            .runeAsButton {
                trailingAction()
            }

        }

    }

}

extension SectionView where Trailing == EmptyView {

    init(leadingTitle: String,
         leadingForegroundColor: RNColorSource = .text(.title),
         showDivider: Bool = false,
         dividerLineWidth: CGFloat = 1.5,
         trailingTitle: String = "View All",
         trailingAction: (() -> Void)? = nil,
         titleFont: RNTheme.FontKey = LeafLaunchThemeTokens.headingFont) {

        self.init(
            leadingTitle: leadingTitle,
            leadingForegroundColor: leadingForegroundColor,
            showDivider: showDivider,
            dividerLineWidth: dividerLineWidth,
            trailingTitle: trailingTitle,
            trailingAction: trailingAction,
            trailingView: nil,
            titleFont: titleFont
        )

    }

}

#Preview {

    @Previewable @Environment(\.style) var style

    RNBaseView {

        VStack(spacing: style.spacing(LLSpacing.listRow)) {

            SectionView(
                leadingTitle: "Section 1",
                showDivider: true
            )

            SectionView(
                leadingTitle: "Section 2",
                showDivider: true,
                trailingTitle: "Show Me More",
                trailingAction: {}
            )

            SectionView(
                leadingTitle: "Section 3",
                showDivider: true,
                dividerLineWidth: 2.5
            )

            SectionView(
                leadingTitle: "Section 4",
                showDivider: true,
                dividerLineWidth: 6
            ) {

                HStack(spacing: style.spacing(LLSpacing.tightMetadata)) {

                    RNImageSource.systemImage("sparkles")
                        .view()
                        .aspectRatio(contentMode: .fit)
                        .frame(
                            width: 16,
                            height: 16
                        )

                    Text("Custom View")
                        .runeFont(with: .BODY_2)

                }
                .runePadding(.vertical, LLSpacing.compact)
                .runePadding(.horizontal, LLSpacing.groupedContent)
                .runeBorder(
                    cornerRadius: .extraLarge,
                    color: .palette(.link)
                )
                .foregroundStyle(RNColorSource.palette(.link))

            }

        }
        .runePadding(.horizontal, LLSpacing.content)

    }

}
