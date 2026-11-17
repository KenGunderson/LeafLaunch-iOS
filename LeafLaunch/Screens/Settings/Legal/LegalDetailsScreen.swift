//
//  LegalDetailsScreen.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 1/23/25.
//

import SwiftUI
import Charts

struct LegalDetailsScreen: View {

    @Environment(\.style) private var style
    @Environment(NavigationService.self) private var navigationService

    @StateObject var viewModel: LegalDetailsViewModel

    var body: some View {

        LLAppHeaderScrollView {
            headerView()
        } scrollViewContent: {
            content()
        }

        // Lifecycle

        .onFirstAppear { [weak viewModel] in

            viewModel?.setup(navigationService: self.navigationService)
            viewModel?.handleFirstAppear()

        }

    }

    @ContentBuilder
    private func headerView() -> some View {

        NavHeader(
            title: self.viewModel.context.displayName,
            leadingNavButtons: [.back],
            leadingNavButtonsAction: { [weak viewModel] _ in viewModel?.dismiss() }
        )

    }

    @ContentBuilder
    private func content() -> some View {

        let items = self.viewModel.legalItems

        VStack(
            alignment: .leading,
            spacing: self.style.spacing(LLSpacing.groupedContent)
        ) {

            let config = Constants.StaggerAnimation.config(interitemSpacing: 16)

            RNStaggeredView(config: config) {

                if !items.isEmpty {

                    legalSections(items)

                }

            }

        }
        .frame(maxWidth: .infinity)
        .animation(
            .spring,
            value: self.viewModel.legalItems
        )

    }

    @ContentBuilder
    private func legalSections(_ items: [LegalItem]) -> some View {

        VStack(
            alignment: .leading,
            spacing: self.style.spacing(LLSpacing.content)
        ) {

            ForEach(items, id: \.id) { item in
                section(legalItem: item)
            }

        }
        .frame(maxWidth: .infinity)

    }

    @ContentBuilder
    private func messageRow(_ message: String) -> some View {

        Text(message)
            .runeFont(with: .BODY_2)
            .runeTextColor(.body)

    }

    @ContentBuilder
    private func section(legalItem: LegalItem) -> some View {

        VStack(
            alignment: .leading,
            spacing: self.style.spacing(LLSpacing.cardContent)
        ) {

            Text(legalItem.title)
                .runeFont(with: LeafLaunchThemeTokens.headingFont)
                .runeTextColor(.title)

            VStack(
                alignment: .leading,
                spacing: self.style.spacing(LLSpacing.groupedContent)
            ) {

                ForEach(legalItem.sections, id: \.self) { message in

                    messageRow(message)

                }

            }
            .frame(maxWidth: .infinity, alignment: .leading)

        }
        .frame(maxWidth: .infinity)

    }

}

#Preview {

    let viewModel = mockResolve(LegalDetailsViewModel.self)
        .setup(context: .termsAndConditions)

    return LegalDetailsScreen(
        viewModel: viewModel
    )
    .withMockServices()

}
