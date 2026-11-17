//
//  Ext+View.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 3/23/26.
//

import SwiftUI

@available(iOS 26.0, *)
public extension View {

    func withDevSettingsOverlay(isEnabled: Bool,
                                action: @escaping () -> Void) -> some View {

        return self
            .onSceneActiveInstall {

                if isEnabled {

                    RNAlwaysOnTopWindowManager.shared.show(.custom("dev-settings")) {

                        RNTokenView(
                            text: "Dev Settings (Hold 2.5 Seconds)",
                            backgroundStyle: .material(.ultraThinMaterial)
                        )
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                            .runePadding(.bottom, LLSpacing.groupedContent)
                            .ignoresSafeArea(edges: .bottom)
                            .simultaneousGesture(LongPressGesture(minimumDuration: 2.5).onEnded { _ in

                                action()

                            })

                    }

                }

            }

    }

}
