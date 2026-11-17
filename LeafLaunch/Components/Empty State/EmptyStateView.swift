//
//  NoContentView.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 8/17/25.
//

import SwiftUI

struct EmptyStateView: View {

    @Environment(\.style) private var style

    let config: EmptyStateConfig

    var body: some View {

        VStack(spacing: self.style.spacing(LLSpacing.section)) {

            self.config
                .image
                .view()
                .aspectRatio(contentMode: .fit)
                .runeTextColor(.title)
                .frame(
                    width: 100,
                    height: 120
                )

            Text(self.config.title)
                .runeFont(with: .HEADER_4)
                .runeTextColor(.title)
                .multilineTextAlignment(.center)

            if let message = self.config.message {

                Text(message)
                    .runeFont(with: .BODY_3)
                    .runeTextColor(.body)
                    .multilineTextAlignment(.center)

            }

            if let actionTitle = self.config.actionTitle {

                LeafLaunchButton(title: actionTitle) {
                    self.config.action?()
                }
                .runePadding(.top, LLSpacing.groupedContent)

            }

        }
        .runePadding(.horizontal, LLSpacing.content)

    }

}

#Preview {

    @Previewable @State var showEmptyState: Bool = true

    RNBaseView {

        ScrollView {

            Group {

                if !showEmptyState {

                    ForEach(0...50) { index in

                        Text("\(index)")
                            .runeFont(with: .TITLE_5)
                            .runeTextColor(.title)

                    }
                    .border(.red)
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .init(.blurReplace)
                    ))

                }

            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

        }

    }
    .emptyStateOverlay(
        shouldShow: showEmptyState,
        config: .init(
            title: "No Clients Found",
            message: "Start building your client base by adding your first client",
            image: .systemImage("magnifyingglass"),
            actionTitle: "Add Your First Client",
            action: {
                print("Do Something")
            }
        ),
        transition: .asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .init(.blurReplace)
        ),
        animation: .bouncy
    )
    .safeAreaInset(edge: .bottom) {

        LeafLaunchButton(title: "Show / Hide") {
            showEmptyState.toggle()
        }
        .runePadding(.horizontal, LLSpacing.content)

    }
    .animation(
        .bouncy,
        value: showEmptyState
    )

}
