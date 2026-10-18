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

    @ViewBuilder
    private func headerView() -> some View {

        NavBarView(
            title: self.viewModel.context.displayName,
            leftButtonView: (
                NavBarButton(style: .back) {
                    self.viewModel.dismiss()
                }
            ).asAnyView()
        )

    }

    @ViewBuilder
    private func content() -> some View {

        let items = self.viewModel.legalItems

        VStack(alignment: .leading) {

            let config = Constants.StaggerAnimation.config(interitemSpacing: 16)

            StaggeredView(config: config) {

                if !items.isEmpty {

                    legalSections(items)

                }

            }

        }
        .frame(maxWidth: .infinity)
        .animation(.spring, value: self.viewModel.legalItems)

    }

    @ViewBuilder
    private func legalSections(_ items: [LegalItem]) -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.large)) {

            ForEach(items, id: \.id) { item in
                section(legalItem: item)
            }

        }
        .frame(maxWidth: .infinity)

    }

    @ViewBuilder
    private func messageRow(_ message: String) -> some View {

        Text(message)
            .appFont(with: .BODY_2)
            .foregroundStyle(.text(.body))

    }

    @ViewBuilder
    private func section(legalItem: LegalItem) -> some View {

        VStack(alignment: .leading,
               spacing: self.style.spacing(.small2)) {

            Text(legalItem.title)
                .appFont(with: .HEADER_3)
                .foregroundStyle(.text(.title))

            VStack(alignment: .leading, spacing: self.style.spacing(.small)) {

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
