//
//  AppRootView.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 6/21/25.
//

import SwiftUI

struct AppRootView<Content: View>: View {

    @Binding var navigationService: NavigationService
    private let content: Content

    init(navigationService: Binding<NavigationService>,
         @ViewBuilder content: () -> Content) {

        self._navigationService = navigationService
        self.content = content()

    }

    init(navigationService: Bindable<NavigationService>,
         @ViewBuilder content: () -> Content) {

        self._navigationService = .constant(navigationService.wrappedValue)
        self.content = content()

    }

    public var body: some View {

        NavigationStack(path: self.$navigationService.routes) {

            self.content
                .withNavigationDestination()
                .withFullScreenCover(self.$navigationService.fullScreenCover)
                .withSheet(self.$navigationService.sheet)

        }

        // Env

        .environment(self.navigationService)

    }

}
