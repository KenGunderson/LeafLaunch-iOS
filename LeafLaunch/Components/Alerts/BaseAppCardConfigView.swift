//
//  BaseAppCardConfig.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 8/19/25.
//

import SwiftUI

struct BaseAppCardConfigView: View {

    @Environment(\.style) private var style

    let image: RNImageSource
    let title: String
    let attributedText: RNAttributedText
    let tintColor: RNColorSource
    let actionTitle: String
    let action: () -> Void

    init(image: RNImageSource,
         title: String,
         attributedText: RNAttributedText,
         tintColor: RNColorSource = .palette(.success),
         actionTitle: String,
         action: @escaping () -> Void) {

        self.image = image
        self.title = title
        self.attributedText = attributedText
        self.tintColor = tintColor
        self.actionTitle = actionTitle
        self.action = action

    }

    var body: some View {

        VStack(spacing: self.style.spacing(LLSpacing.content)) {

            content()
            actionButton()

        }
        .accessibilityAddTraits(.isModal)

    }

    @ContentBuilder
    private func content() -> some View {

        ViewThatFits(in: .vertical) {

            information()
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )

            ScrollView {
                information()
            }
            .scrollBounceBehavior(.basedOnSize)

        }

    }

    @ContentBuilder
    private func information() -> some View {

        VStack(spacing: self.style.spacing(LLSpacing.content)) {

            icon()
            titleMessage()

        }

    }

    @ContentBuilder
    private func icon() -> some View {

        self.image
            .view()
            .aspectRatio(contentMode: .fit)
            .frame(height: 80)
            .foregroundStyle(self.tintColor)
            .accessibilityHidden(true)

    }

    @ContentBuilder
    private func titleMessage() -> some View {

        Group {

            Text(self.title)
                .runeFont(with: .HEADER_3)
                .runeTextColor(.title)
                .multilineTextAlignment(.center)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )
                .accessibilityAddTraits(.isHeader)

            self.attributedText
                .multilineTextAlignment(.center)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )
                .runePadding(.top, .custom(-self.style.spacing(LLSpacing.section)))
                .runePadding(.horizontal, LLSpacing.pageInset)

        }

    }

    @ContentBuilder
    private func actionButton() -> some View {

        LeafLaunchButton(title: self.actionTitle) {
            self.action()
        }
        .runePadding(.horizontal, LLSpacing.pageInset)

    }

}

#Preview {

    @Previewable @Environment(\.style) var style: any RNStyleProtocol

    let alertService = mockResolve(RNAlertServiceProtocol.self)

    RNBaseView(alignment: .bottom) {

        VStack(spacing: style.spacing(LLSpacing.listRow)) {

            LeafLaunchButton(title: "Show Alert") {

                alertService.showAlert(
                    .init(.card(.invitationAlert(
                        name: "Sako Hovaguimian",
                        businessName: "Bronx Tales",
                        style: style
                    ) {
                        print("Testing")
                    }
                    )))

            }

            LeafLaunchButton(title: "Show Alert") {

                alertService.showAlert(.init(
                    .card(.init(
                        viewBuilder: { dismissAction in

                                        BaseAppCardConfigView(
                                            image: .systemImage("person.fill"),
                                            title: "Test App Card Action",
                                            attributedText: .init(content: { Text("This is the message of the app card. It is a long message that needs to be wrapped to multiple lines. It is a long message that needs to be wrapped to multiple lines. It is a long message that needs to be wrapped to multiple lines.") }),
                                            actionTitle: "Complete"
                                        ) {
                                            dismissAction()
                                        }
                                        .asAnyView()

                                    },
                        cornerRadius: .theme(.extraLarge),
                        backgroundCardInset: .init(
                            top: 0,
                            left: 24,
                            bottom: style.spacing(LLSpacing.content),
                            right: 24
                        ),
                        contentCardInset: .init(
                            top: 40,
                            left: 16,
                            bottom: 40,
                            right: 16
                        ),
                        cardBackgroundColor: .background(.secondary),
                        shouldDismissOnOutsideTouch: false,
                        shouldDismissOnDrag: true
                    ))))

            }

        }
        .runePadding(.horizontal, .extraLarge)

    }
    .withMockServices()

}
