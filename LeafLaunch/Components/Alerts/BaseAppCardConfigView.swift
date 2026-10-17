//
//  BaseAppCardConfig.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 8/19/25.
//

import SwiftUI

struct BaseAppCardConfigView: View {

    @Environment(\.style) private var style

    let image: ImageSource
    let title: String
    let attributedText: AttributedText
    let tintColor: ColorSource
    let actionTitle: String
    let action: () -> Void

    init(image: ImageSource,
         title: String,
         attributedText: AttributedText,
         tintColor: ColorSource = .palette(.success),
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

        VStack(spacing: self.style.spacing(.large)) {

            content()
            actionButton()

        }
        .accessibilityAddTraits(.isModal)

    }

    @ViewBuilder
    private func content() -> some View {

        ViewThatFits(in: .vertical) {

            information()
                .fixedSize(horizontal: false, vertical: true)

            ScrollView {
                information()
            }
            .scrollBounceBehavior(.basedOnSize)

        }

    }

    @ViewBuilder
    private func information() -> some View {

        VStack(spacing: self.style.spacing(.large)) {

            icon()
            titleMessage()

        }

    }

    @ViewBuilder
    private func icon() -> some View {

        self.image
            .view()
            .aspectRatio(contentMode: .fit)
            .frame(height: 80)
            .foregroundStyle(self.tintColor)
            .accessibilityHidden(true)

    }

    @ViewBuilder
    private func titleMessage() -> some View {

        Group {

            Text(self.title)
                .appFont(with: .HEADER_3)
                .foregroundStyle(.text(.title))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)

            self.attributedText
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, -self.style.spacing(.small2))
                .padding(.horizontal, .medium)

        }

    }

    @ViewBuilder
    private func actionButton() -> some View {

        LeafLaunchButton(title: self.actionTitle) {
            self.action()
        }
        .padding(.horizontal, .medium)

    }

}

#Preview {

    let alertService = mockResolve(AlertServiceProtocol.self)

    AppBaseView(alignment: .bottom) {

        VStack {

            CommonButton(title: "Show Alert") {

                alertService.showAlert(
                    .init(.card(.invitationAlert(
                        name: "Sako Hovaguimian",
                        businessName: "Bronx Tales"
                    ) {
                        print("Testing")
                    }
                    )))

            }

            CommonButton(title: "Show Alert") {

                alertService.showAlert(.init(
                    .card(.init(viewBuilder: { dismissAction in

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
                                cornerRadius: Style.shared.radius(.extraLarge),
                                backgroundCardInset: .init(top: 0, left: 24, bottom: Style.shared.spacing(.large), right: 24),
                                contentCardInset: .init(top: 40, left: 16, bottom: 40, right: 16),
                                cardBackgroundColor: .background(.secondary),
                                shouldDismissOnOutsideTouch: false,
                                shouldDismissOnDrag: true
                        ))))

            }

        }
        .padding(.horizontal, .extraLarge)

    }
    .withMockServices()

}
