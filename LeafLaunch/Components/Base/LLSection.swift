//
//  LLSection.swift
//  LeafLaunch
//

import SwiftUI

struct LLSection<Content: View>: View {

    @Environment(\.style) private var style

    private let title: String
    private let titleFont: RNTheme.FontKey
    private let titleColor: RNColorSource
    private let imageSource: RNImageSource?
    private let imageColor: RNColorSource
    private let imageSize: CGFloat
    private let actionTitle: String
    private let actionFont: RNTheme.FontKey
    private let actionColor: RNColorSource
    private let action: (() -> Void)?
    private let alignment: HorizontalAlignment
    private let headingSpacing: RNTheme.SpacingKey
    private let contentSpacing: RNTheme.SpacingKey
    private let headingHorizontalPadding: RNTheme.SpacingKey
    private let content: Content

    init(title: String,
         titleFont: RNTheme.FontKey = LeafLaunchThemeTokens.headingFont,
         titleColor: RNColorSource = .text(.title),
         imageSource: RNImageSource? = nil,
         imageColor: RNColorSource = .palette(.link),
         imageSize: CGFloat = 20,
         actionTitle: String = "View All",
         actionFont: RNTheme.FontKey = .TITLE_2,
         actionColor: RNColorSource = .palette(.link),
         action: (() -> Void)? = nil,
         alignment: HorizontalAlignment = .leading,
         headingSpacing: RNTheme.SpacingKey = LLSpacing.section,
         contentSpacing: RNTheme.SpacingKey = LLSpacing.groupedContent,
         headingHorizontalPadding: RNTheme.SpacingKey = LLSpacing.none,
         @ContentBuilder content: () -> Content) {

        self.title = title
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.imageSource = imageSource
        self.imageColor = imageColor
        self.imageSize = imageSize
        self.actionTitle = actionTitle
        self.actionFont = actionFont
        self.actionColor = actionColor
        self.action = action
        self.alignment = alignment
        self.headingSpacing = headingSpacing
        self.contentSpacing = contentSpacing
        self.headingHorizontalPadding = headingHorizontalPadding
        self.content = content()

    }

    var body: some View {

        let contentAlignment = Alignment(
            horizontal: self.alignment,
            vertical: .top
        )

        VStack(
            alignment: self.alignment,
            spacing: self.style.spacing(self.headingSpacing)
        ) {

            header()

            VStack(
                alignment: self.alignment,
                spacing: self.style.spacing(self.contentSpacing)
            ) {
                self.content
            }
            .frame(maxWidth: .infinity, alignment: contentAlignment)

        }

    }

    @ContentBuilder
    private func header() -> some View {

        CommerceSectionHeader(
            title: self.title,
            actionTitle: self.actionTitle,
            action: self.action,
            titleFont: self.titleFont,
            titleColor: self.titleColor,
            imageSource: self.imageSource,
            imageColor: self.imageColor,
            imageSize: self.imageSize,
            actionFont: self.actionFont,
            actionColor: self.actionColor
        )
        .runePadding(.horizontal, self.headingHorizontalPadding)

    }

}

#Preview {

    RNBaseView {

        LLSection(
            title: "Field Notes",
            imageSource: .systemImage("book"),
            actionTitle: "Add Note",
            action: {}
        ) {

            Text("A little space for your next idea.")
                .runeFont(with: .BODY_3)
                .runeTextColor(.body)

        }

    }
    .withMockPreviews()

}
